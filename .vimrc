set nocompatible  " Use Vim defaults

execute pathogen#infect()

set backspace=indent,eol,start  " reasonable backspace in insert mode

set modelines=0   " Modelines are a security hazard

" Formatting
set expandtab   " Automatically expand tabs to spaces
set tabstop=2   " tab width
set shiftwidth=2  " wide, otherwise it's tabstop wide
set softtabstop=2   " Simulated tabstop of 4 by using spaces and tabs
set textwidth=78  " where to wrap lines
set fo=crq      " when to wrap lines
set autoindent  " set auto-indenting on

" Display
"set ruler   " show the cursor position
set nowrap  " don't warp display

" Add columns at 80 and 120 characters to warn about line length
let &colorcolumn=join(range(81,999),",")
let &colorcolumn="80,".join(range(120,999),",")

set laststatus=2
set encoding=utf-8

set showmatch   " show matching brackets
set showcmd   " show (partial) command in status line

set wildmenu
set wildmode=list:longest,full

" define Browse command to work around fugitive Gbrowse issue
" see
" https://github.com/tpope/vim-fugitive/commit/32957cb55235e82ac42147f073326db273b89b0f
" and https://github.com/tpope/vim-fugitive/issues/530#issuecomment-50277936
"command! -bar -nargs=1 Browse silent! exe '!open' shellescape(<q-args>, 1) | redraw!
" OR this might be a better fix - see
" https://github.com/aroben/dotfiles/commit/648cfddf16fc4a612a1c6efd59525e6946048e50
let g:netrw_browsex_viewer = "open"

" Searching
set incsearch   " incremental search
set infercase   " handle case in a smart way in autocompletes
set ignorecase  " ignore case in search
set smartcase   " unless the search string contains uppercase
set hlsearch  " highlighted search
"nnoremap <C-L> :noh<CR><C-L>

" Use fzf in Vim
set rtp+=$(brew --prefix)/opt/fzf

" Display whitespace characters nicely when using 'set list'
set listchars=eol:$,tab:>-,trail:-,extends:>,precedes:<

filetype plugin on    " enable filetype detection
filetype indent on    " enable language-depenent indentation

" TODO is this actually used?
runtime macros/matchit.vim

syntax enable
set background=dark
"set t_Co=16
"let g:solarized_termtrans=1
colorscheme solarized
highlight clear SignColumn

" AIRLINE

" disable Bufferline and instead just display buffer number and file name
let g:airline#extensions#bufferline#enabled = 0
let g:airline_section_c = '%n: %f'

" truncate branch names in Airline
let g:airline#extensions#branch#format = 2
let g:airline#extensions#branch#displayed_head_limit = 20

" only display file encoding if it is not `utf-8[unix]`
let g:airline#parts#ffenc#skip_expected_string='utf-8[unix]'

" various display settings
let g:airline_powerline_fonts = 1
let g:airline_detect_modified = 0
let g:airline_theme = 'luna'
let g:airline_base16_improved_contrast = 1 " make inactive statusline stand out a bit more

" symbols
if !exists('g:airline_symbols')
  let g:airline_symbols = {}
endif
let g:airline_left_sep = '⮀'
let g:airline_left_alt_sep = '⮁'
let g:airline_right_sep = '⮂'
let g:airline_right_alt_sep = '⮃'
let g:airline_symbols.branch = '⭠'
let g:airline_symbols.readonly = '⭤'
let g:airline_symbols.colnr = ' ℅:'
let g:airline_symbols.linenr = ' ⭡:'
let g:airline_symbols.maxlinenr = '' "don't want a symbol for this
let g:airline_symbols.dirty = ' ✹'
let g:airline_symbols.whitespace = 'Ξ'
let g:airline_symbols.notexists = '¡'
let g:airline_inactive_collapse=1

" syntastic error/warning display
let airline#extensions#syntastic#error_symbol = 'Err: '
let airline#extensions#syntastic#stl_format_err = '%E{%fe/%e}'
let airline#extensions#syntastic#warning_symbol = 'Warn: '
let airline#extensions#syntastic#stl_format_warn = '%W{%fw/%w}'

" SYNTASTIC
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
let g:syntastic_mode_map = {
      \ "mode": "active",
      \ "active_filetypes": [],
      \ "passive_filetypes": ["go"] } "conflicts with vim-go
let g:go_list_type = "quickfix"
" TODO could edit the error/warn/style signs, maybe later

" CLOJURE

"  Parentheses colours using Solarized
let g:rbpt_colorpairs = [
  \ [ '13', '#6c71c4'],
  \ [ '5',  '#d33682'],
  \ [ '1',  '#dc322f'],
  \ [ '9',  '#cb4b16'],
  \ [ '3',  '#b58900'],
  \ [ '2',  '#859900'],
  \ [ '6',  '#2aa198'],
  \ [ '4',  '#268bd2'],
  \ ]

"let g:rbpt_max = 16
"let g:rbpt_loadcmd_toggle = 0
au VimEnter * RainbowParenthesesToggle
au Syntax * RainbowParenthesesLoadRound
au Syntax * RainbowParenthesesLoadSquare
au Syntax * RainbowParenthesesLoadBraces


" from https://github.com/puppetlabs/pl-clojure-style/blob/master/indents.vim
" Use this with vim-clojure-static
" It's pretty close but the indentation engine is quite weak so it won't
" completely match cljfmt
" See vim-cljfmt for in-editor support
let g:clojure_align_subforms = 1
autocmd FileType clojure setlocal lispwords+=GET,POST,PUT,DELETE,HEAD,ANY,context,cond
let g:clojure_fuzzy_indent_patterns = ['^with', '^def', '^let', '^\.']
let g:clojure_special_indent_words = 'deftype,defrecord,reify,proxy,extend-type,extend-protocol,letfn,defservice'

" always indent 2 spaces in clojure code
" (from https://github.com/guns/vim-clojure-static/issues/36#issuecomment-29139119)
"let g:clojure_fuzzy_indent = 1
"let g:clojure_fuzzy_indent_patterns = ['.']
"let g:clojure_fuzzy_indent_blacklist = []

let g:slime_target = "tmux"

" RUBY
let ruby_space_errors=1   " highlight tab/space mixing in ruby files

" don't do this for go though :/
" actually this isn't ruby specific
if (! &filetype =='go')
  highlight RedundantSpaces ctermbg=red
  match RedundantSpaces /\s\+$\| \+\ze\t\|\t/
endif

" GO
" from https://github.com/fatih/vim-go-tutorial
" shortcut for running :GoTest
autocmd FileType go nmap <leader>t  <Plug>(go-test)
" shortcut for running :GoBuild
autocmd FileType go nmap <leader>b  <Plug>(go-build)
" Note to self: :GoDef is C-], go back is C-o
" additional highlighting for Go - can cause performance issues
let g:go_highlight_types = 1
let g:go_highlight_fields = 1
let g:go_highlight_functions = 1
let g:go_highlight_function_calls = 1
let g:go_highlight_operators = 1
let g:go_fmt_command = "goimports"

" PYTHON
" conform to PEP08 standards (from https://realpython.com/blog/python/vim-and-python-a-match-made-in-heaven )
au BufNewFile,BufRead *.py
 \ set tabstop=4 |
 \ set softtabstop=4 |
 \ set shiftwidth=4 |
 \ set fileformat=unix
" don't include since already set
    "\ set textwidth=79
    "\ set expandtab
    "\ set autoindent
    "
    "

" JSON
autocmd BufNewFile,BufRead *.json set ft=javascript

" MISC

set number  " line numbers
set scrolloff=5
let loaded_matchparen=1
set hidden

set nobackup
set noswapfile

" Map CtrlP to FZF
nnoremap <C-p> :FZF<CR>

" mappings for finding files with fzf.vim
map <Leader>f :Files<CR>
map <Leader>g :GFiles<CR>

map <C-n> :NERDTreeToggle<CR>
nnoremap <silent> <Leader>n :NERDTreeFind<CR>
" close vim if nerdtree is the only window left open
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

set pastetoggle=<F2>

" MARKDOWN

let g:vim_markdown_folding_disabled=1

augroup markdown
    au!
    au BufNewFile,BufRead *.md,*.markdown setlocal wrap linebreak nolist textwidth=0 " softwrap in markdown files
augroup END

command! SoftWrap set wrap linebreak nolist

" Remap j and k to act as expected when used on long, wrapped, lines
nnoremap j gj
nnoremap k gk

" LATEX

let g:Tex_DefaultTargetFormat='pdf'
"autocmd FileType tex call Tex_SetTeXCompilerTarget('View','pdf')

"let g:tex_flavor='latex'
let g:Tex_TreatMacViewerAsUNIX = 1
let g:Tex_ExecuteUNIXViewerInForeground = 1
let g:Tex_ViewRule_ps = 'open -a Preview'
let g:Tex_ViewRule_pdf = 'open -a Preview'
