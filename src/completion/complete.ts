'use strict'
import { Neovim } from '@chemzqm/neovim'
import { CancellationToken, CancellationTokenSource, Emitter, Event, Position } from 'vscode-languageserver-protocol'
import Document from '../model/document'
import { CompleteOption, DurationCompleteItem, ISource, SourceType } from '../types'
import { wait } from '../util'
import { isFalsyOrEmpty } from '../util/array'
import { byteSlice, characterIndex } from '../util/string'
import { fuzzyScore, fuzzyScoreGracefulAggressive, FuzzyScorer } from '../util/filter'
import { ConvertOption, toDurationCompleteItem } from './util'
import { WordDistance } from './wordDistance'
import { createLogger } from '../logger'
const logger = createLogger('completion-complete')
const MAX_DISTANCE = 2 << 20

export interface CompleteConfig {
  asciiMatch: boolean
  autoTrigger: string
  filterGraceful: boolean
  snippetsSupport: boolean
  languageSourcePriority: number
  triggerCompletionWait: number
  minTriggerInputLength: number
  triggerAfterInsertEnter: boolean
  acceptSuggestionOnCommitCharacter: boolean
  maxItemCount: number
  timeout: number
  localityBonus: boolean
  highPrioritySourceLimit: number
  lowPrioritySourceLimit: number
  removeDuplicateItems: boolean
  defaultSortMethod: string
  asciiCharactersOnly: boolean
  enableFloat: boolean
  ignoreRegexps: ReadonlyArray<string>
}

export interface CompleteResultToFilter {
  items: DurationCompleteItem[]
  isIncomplete?: boolean
  startcol?: number
}

export type Callback = () => void

export default class Complete {
  // identify this complete
  private results: Map<string, CompleteResultToFilter> = new Map()
  private _input = ''
  private _completing = false
  private tokenSource: CancellationTokenSource
  private timer: NodeJS.Timer
  private names: string[] = []
  private readonly _onDidRefresh = new Emitter<void>()
  private wordDistance: WordDistance | undefined
  public readonly onDidRefresh: Event<void> = this._onDidRefresh.event
  private asciiMatch: boolean
  constructor(public option: CompleteOption,
    private document: Document,
    private config: CompleteConfig,
    private sources: ISource[],
    private nvim: Neovim) {
    this.tokenSource = new CancellationTokenSource()
    sources.sort((a, b) => (b.priority ?? 99) - (a.priority ?? 99))
    this.names = sources.map(o => o.name)
    this.asciiMatch = config.asciiMatch && option.input.length > 0 && option.input.charCodeAt(0) < 128
  }

  private fireRefresh(waitTime: number): void {
    if (this.timer) clearTimeout(this.timer)
    this.timer = setTimeout(() => {
      this._onDidRefresh.fire()
    }, waitTime)
  }

  private get totalLength(): number {
    let len = 0
    for (let result of this.results.values()) {
      len += result.items.length
    }
    return len
  }

  private getPriority(source: ISource): number {
    if (typeof source.priority === 'number') {
      return source.priority
    }
    if (source.sourceType === SourceType.Service) {
      return this.config.languageSourcePriority
    }
    return 0
  }

  public get isCompleting(): boolean {
    return this._completing
  }

  public get input(): string {
    return this._input
  }

  public get isEmpty(): boolean {
    return this.results.size === 0
  }

  public getIncompleteSources(): string[] {
    let names: string[] = []
    for (let [name, result] of this.results.entries()) {
      if (result.isIncomplete) {
        names.push(name)
      }
    }
    return names
  }

  public async doComplete(): Promise<boolean> {
    let token = this.tokenSource.token
    let res = await Promise.all([
      this.nvim.call('coc#util#synname', []),
      this.nvim.call('coc#util#suggest_variables', [this.option.bufnr]),
      this.document.patchChange()
    ]) as [string, { disable: boolean, disabled_sources: string[], blacklist: string[] }, undefined]
    if (token.isCancellationRequested) return
    this.option.synname = res[0]
    let variables = res[1]
    if (variables.disable) {
      logger.warn('suggest cancelled by b:coc_suggest_disable')
      return true
    }
    if (!isFalsyOrEmpty(variables.disabled_sources)) {
      this.sources = this.sources.filter(s => !variables.disabled_sources.includes(s.name))
      if (this.sources.length === 0) {
        logger.warn('suggest cancelled by b:coc_disabled_sources')
        return true
      }
    }
    if (!isFalsyOrEmpty(variables.blacklist) && variables.blacklist.includes(this.option.input)) {
      logger.warn('suggest cancelled by b:coc_suggest_blacklist')
      return true
    }
    await wait(Math.min(this.config.triggerCompletionWait ?? 0, 50))
    if (token.isCancellationRequested) return
    await this.completeSources(this.sources, false)
  }

  private async completeSources(sources: ReadonlyArray<ISource>, isFilter: boolean): Promise<void> {
    let { timeout, localityBonus } = this.config
    let { results, tokenSource, } = this
    timeout = timeout ?? 500
    let col = this.option.col
    let names = sources.map(s => s.name)
    let total = names.length
    this._completing = true
    let token = tokenSource.token
    let timer: NodeJS.Timer
    let tp = new Promise<void>(resolve => {
      timer = setTimeout(() => {
        if (!token.isCancellationRequested) {
          names = names.filter(n => !finished.includes(n))
          tokenSource.cancel()
          logger.warn(`Completion timeout after ${timeout}ms`, names)
          this.nvim.setVar(`coc_timeout_sources`, names, true)
        }
        resolve()
      }, timeout)
    })
    const finished: string[] = []
    let promises = [
      isFilter ? Promise.resolve() : WordDistance.create(localityBonus, this.option, token).then(instance => {
        if (token.isCancellationRequested) return
        this.wordDistance = instance
      }),
      ...sources.map(s => this.completeSource(s, token).then(() => {
        finished.push(s.name)
        if (token.isCancellationRequested || isFilter) return
        let colChanged = this.option.col !== col
        if (colChanged) this.cancel()
        if (colChanged || finished.length === total) {
          this.fireRefresh(0)
        } else if (results.has(s.name)) {
          this.fireRefresh(16)
        }
      }))
    ]
    await Promise.race([tp, Promise.all(promises)])
    clearTimeout(timer)
    this._completing = false
  }

  private async completeSource(source: ISource, token: CancellationToken): Promise<void> {
    // new option for each source
    let opt = Object.assign({}, this.option)
    let { asciiMatch } = this
    const sourceName = source.name
    try {
      if (typeof source.shouldComplete === 'function') {
        let shouldRun = await Promise.resolve(source.shouldComplete(opt))
        if (!shouldRun || token.isCancellationRequested) return
      }
      const priority = this.getPriority(source)
      const start = Date.now()
      await new Promise<void>((resolve, reject) => {
        Promise.resolve(source.doComplete(opt, token)).then(result => {
          if (token.isCancellationRequested) {
            resolve(undefined)
            return
          }
          let len = result ? result.items.length : 0
          logger.debug(`Source "${sourceName}" finished with ${len} items ${Date.now() - start}ms`)
          if (len > 0) {
            const convertOption: ConvertOption = { asciiMatch, itemDefaults: result.itemDefaults, prefix: result.prefix }
            const items = result.items.map((item, index: number) => toDurationCompleteItem(item, index, sourceName, priority, convertOption, opt))
            // avoid col change when no match exists
            if (result.prefix && !items.some(o => o.filterText.includes(result.prefix))) {
              this.results.delete(sourceName)
              return
            }
            this.setResult(sourceName, { items, isIncomplete: result.isIncomplete, startcol: result.startcol })
          } else {
            this.results.delete(sourceName)
          }
          resolve()
        }, err => {
          reject(err)
        })
      })
    } catch (err) {
      // this.nvim.echoError(err)
      logger.error('Complete error:', source.name, err)
    }
  }

  public async completeInComplete(resumeInput: string, names: string[]): Promise<DurationCompleteItem[] | undefined> {
    let { document } = this
    this.cancel()
    this.tokenSource = new CancellationTokenSource()
    let token = this.tokenSource.token
    await document.patchChange(true)
    if (token.isCancellationRequested) return undefined
    let { input, colnr, linenr, followWord, position } = this.option
    let word = resumeInput + followWord
    Object.assign(this.option, {
      word,
      input: resumeInput,
      line: document.getline(linenr - 1),
      position: { line: position.line, character: position.character + resumeInput.length - input.length },
      colnr: colnr + (resumeInput.length - input.length),
      triggerCharacter: undefined,
      triggerForInComplete: true
    })
    let sources = this.sources.filter(s => names.includes(s.name))
    await this.completeSources(sources, true)
    if (token.isCancellationRequested) return undefined
    return this.filterItems(resumeInput)
  }

  public filterItems(input: string): DurationCompleteItem[] | undefined {
    let { results, names, option } = this
    this._input = input
    if (results.size == 0) return []
    let len = input.length
    let anchor = Position.create(option.linenr - 1, characterIndex(option.line, option.col))
    let emptyInput = len == 0
    let { maxItemCount, defaultSortMethod, removeDuplicateItems } = this.config
    let arr: DurationCompleteItem[] = []
    let words: Set<string> = new Set()
    const lowInput = input.toLowerCase()
    const scoreFn: FuzzyScorer = (!this.config.filterGraceful || this.totalLength > 2000) ? fuzzyScore : fuzzyScoreGracefulAggressive
    for (let name of names) {
      let result = results.get(name)
      if (!result) continue
      let items = result.items
      for (let idx = 0; idx < items.length; idx++) {
        let item = items[idx]
        let { word, filterText, dup } = item
        if (dup !== 1 && words.has(word)) continue
        if (filterText.length < len) continue
        if (removeDuplicateItems && item.isSnippet !== true && words.has(word)) continue
        if (!emptyInput) {
          let res = scoreFn(input, lowInput, 0, filterText, filterText.toLowerCase(), 0)
          if (res == null) continue
          item.score = res[0]
          item.positions = res
          if (this.wordDistance) item.localBonus = MAX_DISTANCE - this.wordDistance.distance(anchor, item)
        }
        words.add(word)
        arr.push(item)
      }
    }
    arr.sort((a, b) => {
      let sa = a.sortText
      let sb = b.sortText
      if (!emptyInput && a.score !== b.score) return b.score - a.score
      if (a.priority !== b.priority) return b.priority - a.priority
      if (a.source === b.source && sa !== sb) return sa < sb ? -1 : 1
      if (a.localBonus !== b.localBonus) return b.localBonus - a.localBonus
      // not sort with empty input
      if (input.length === 0) return 0
      switch (defaultSortMethod) {
        case 'none':
          return 0
        case 'alphabetical':
          return a.filterText.localeCompare(b.filterText)
        case 'length':
        default: // Fallback on length
          return a.filterText.length - b.filterText.length
      }
    })
    return this.limitCompleteItems(arr.slice(0, maxItemCount))
  }

  public async filterResults(input: string): Promise<DurationCompleteItem[] | undefined> {
    clearTimeout(this.timer)
    if (input !== this.option.input) {
      let names = this.getIncompleteSources()
      if (names.length) {
        return await this.completeInComplete(input, names)
      }
    }
    return this.filterItems(input)
  }

  private limitCompleteItems(items: DurationCompleteItem[]): DurationCompleteItem[] {
    let { highPrioritySourceLimit, lowPrioritySourceLimit } = this.config
    if (!highPrioritySourceLimit && !lowPrioritySourceLimit) return items
    let counts: Map<string, number> = new Map()
    return items.filter(item => {
      let { priority, source } = item
      let isLow = priority < 90
      let curr = counts.get(source) || 0
      if ((lowPrioritySourceLimit && isLow && curr == lowPrioritySourceLimit)
        || (highPrioritySourceLimit && !isLow && curr == highPrioritySourceLimit)) {
        return false
      }
      counts.set(source, curr + 1)
      return true
    })
  }

  // handle startcol change
  private setResult(name: string, result: CompleteResultToFilter): void {
    let { results } = this
    let { line, colnr, col } = this.option
    if (typeof result.startcol === 'number' && result.startcol != col) {
      let { startcol } = result
      logger.warn(`startcol changed to ${startcol} by source ${name}`)
      this.option.col = startcol
      this.option.input = byteSlice(line, startcol, colnr - 1)
      results.clear()
      results.set(name, result)
    } else {
      results.set(name, result)
    }
  }

  public cancel(): void {
    let { tokenSource, timer } = this
    if (timer) clearTimeout(timer)
    tokenSource.cancel()
    this._completing = false
  }

  public dispose(): void {
    this.cancel()
    this._onDidRefresh.dispose()
  }
}
