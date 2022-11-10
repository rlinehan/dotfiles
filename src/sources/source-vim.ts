'use strict'
import { CancellationToken, Range } from 'vscode-languageserver-protocol'
import { CompleteOption, CompleteResult, DurationCompleteItem, ExtendedCompleteItem } from '../types'
import { fuzzyChar } from '../util/fuzzy'
import { byteSlice, characterIndex } from '../util/string'
import snippetManager from '../snippets/manager'
import workspace from '../workspace'
import Source from './source'
import { getLineAndPosition } from '../core/ui'

export default class VimSource extends Source {

  private async callOptionalFunc(fname: string, args: any[]): Promise<any> {
    let exists = this.optionalFns.includes(fname)
    if (!exists) return null
    let name = `coc#source#${this.name}#${fname}`
    return await this.nvim.call(name, args)
  }

  public async shouldComplete(opt: CompleteOption): Promise<boolean> {
    let shouldRun = await super.shouldComplete(opt)
    if (!shouldRun) return false
    if (!this.optionalFns.includes('should_complete')) return true
    let res = await this.callOptionalFunc('should_complete', [opt])
    return !!res
  }

  public async refresh(): Promise<void> {
    await this.callOptionalFunc('refresh', [])
  }

  public async insertSnippet(insertText: string, opt: CompleteOption): Promise<void> {
    let pos = await getLineAndPosition(this.nvim)
    let { line, col } = opt
    let oldIndent = line.match(/^\s*/)[0]
    let newIndent = pos.text.match(/^\s*/)[0]
    // current insert range
    let range = Range.create(pos.line, characterIndex(line, col) + newIndent.length - oldIndent.length, pos.line, pos.character)
    await snippetManager.insertSnippet(insertText, true, range)
  }

  public async onCompleteDone(item: DurationCompleteItem, opt: CompleteOption): Promise<void> {
    if (this.optionalFns.includes('on_complete')) {
      await this.callOptionalFunc('on_complete', [item])
    } else if (item.isSnippet && item.insertText) {
      await this.insertSnippet(item.insertText, opt)
    }
  }

  public onEnter(bufnr: number): void {
    if (!this.optionalFns.includes('on_enter')) return
    let doc = workspace.getDocument(bufnr)
    if (!doc) return
    let { filetypes } = this
    if (filetypes && !filetypes.includes(doc.filetype)) return
    void this.callOptionalFunc('on_enter', [{
      bufnr,
      uri: doc.uri,
      languageId: doc.filetype
    }])
  }

  public async doComplete(opt: CompleteOption, token: CancellationToken): Promise<CompleteResult | null> {
    let { col, input, line, colnr } = opt
    let startcol: number | null = await this.callOptionalFunc('get_startcol', [opt])
    if (token.isCancellationRequested) return
    if (startcol) {
      if (startcol < 0) return null
      startcol = Number(startcol)
      // invalid startcol
      if (isNaN(startcol) || startcol < 0) startcol = col
      if (startcol !== col) {
        input = byteSlice(line, startcol, colnr - 1)
        opt = Object.assign({}, opt, {
          col: startcol,
          changed: col - startcol,
          input
        })
      }
    }
    let items = await this.nvim.callAsync('coc#util#do_complete', [this.name, opt]) as ExtendedCompleteItem[]
    if (!items || items.length == 0 || token.isCancellationRequested) return null
    if (this.firstMatch && input.length) {
      let ch = input[0]
      items = items.filter(item => {
        let cfirst = item.filterText ? item.filterText[0] : item.word[0]
        return fuzzyChar(ch, cfirst)
      })
    }
    items = items.map(item => {
      if (typeof item == 'string') {
        return { word: item, menu: this.menu, isSnippet: this.isSnippet }
      }
      let menu = item.menu ? item.menu + ' ' : ''
      item.menu = `${menu}${this.menu}`
      item.isSnippet = typeof item.isSnippet === 'boolean' ? item.isSnippet : this.isSnippet
      return item
    })
    let res: CompleteResult = { items }
    if (startcol) res.startcol = startcol
    return res
  }
}
