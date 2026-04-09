set nowrap
set ic
set number
set hlsearch
set clipboard=unnamedplus
filetype off                  " required
" let g:auto_save = 1  " enable AutoSave on Vim startup
" set list
" set listchars=tab:▸\ ,trail:·,space:·,eol:↲,nbsp:␣

call plug#begin('~/.vim/plugged')
" Specify a directory for plugins call plug#begin('~/.vim/plugged')
Plug 'ntpeters/vim-better-whitespace' " Highlight trailing whitespace
" Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'pylover/c-syntax.vim'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'python-mode/python-mode', { 'for': 'python', 'branch': 'develop' }
Plug 'tmhedberg/SimpylFold'
Plug 'vim-scripts/indentpython.vim'
Plug 'scrooloose/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'plasticboy/vim-markdown'
Plug 'mgedmin/coverage-highlight.vim'
Plug 'tell-k/vim-autopep8'
Plug 'liuchengxu/space-vim-dark'
Plug 'evanleck/vim-svelte', {'branch': 'main'}
Plug 'prettier/vim-prettier', { 'do': 'npm install' }
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
Plug 'mrk21/yaml-vim' " For YAML syntax/indentation
Plug 'Exafunction/codeium.vim', { 'branch': 'main' } " codeium
Plug 'rodjek/vim-puppet' " For Puppet syntax highlighting
Plug 'elzr/vim-json' " For metadata.json
" Jinja2
Plug 'Glench/Vim-Jinja2-Syntax'
"Plug 'https://github.com/lepture/vim-jinja.git
"" Snippets
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'
Plug 'fatih/vim-hclfmt'               " HCL formatting
" python
"" Python Bundle
Plug 'davidhalter/jedi-vim'
Plug 'raimon49/requirements.txt.vim', {'for': 'requirements'}

Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim' " Fuzzy Finder vim plugin
Plug 'rust-lang/rust.vim' " Rust syntax highlighting
Plug 'https://github.com/907th/vim-auto-save.git' " Auto save
" Haskell
" Plug 'neovimhaskell/haskell-vim'
" To be removed
"Plug 'kien/ctrlp.vim'
"Plug 'jistr/vim-nerdtree-tabs'
"Plug 'godlygeek/tabular'
"Plug 'itchyny/lightline.vim'
"
" Ocaml
"Plug 'scrooloose/syntastic'
"Plug 'def-lkb/merlin'
"Plug 'jpalardy/vim-slime'
"Plug 'OCamlPro/ocp-indent'
call plug#end()

" Use <Enter> to confirm selections in the coc.nvim suggestion list
inoremap <expr> <CR> coc#pum#visible() ? coc#pum#confirm() : "\<CR>"

au filetype go inoremap <buffer> . .<C-x><C-o>

" https://github.com/Yggdroot/indentLine
let g:indentLine_char_list = ['|', '¦', '┆', '┊']
" Enable the visibility of hidden files in NERDTree
let NERDTreeShowHidden=1
syntax on
filetype plugin indent on    " required

set nopaste

" https://github.com/ycm-core/YouCompleteMe/issues/4134#issuecomment-1446235584
" packadd YouCompleteMe


" Spell checking
setlocal spell spelllang=en_us
set nospell


" split and navigation
set splitbelow
set splitright
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

" Enable folding
set foldmethod=indent
set foldlevel=79
set colorcolumn=79


" Enable folding with the space bar
nnoremap <space> za
" you have changed me
set textwidth=200
set tabstop=4
set softtabstop=4
set autoindent
set cindent
set noexpandtab
set shiftwidth=4   
 
" Python, PEP8
au BufNewFile,BufRead *.py  
    \ setlocal tabstop=4 |
    \ setlocal softtabstop=4 |
    \ setlocal shiftwidth=4 |
    \ setlocal textwidth=79 |
    \ setlocal expandtab |
    \ setlocal autoindent |
    \ setlocal fileformat=unix

" c
set cindent
au BufRead,BufNewFile *.c,*.h,*.in,*.cpp,*.ino
    \ setlocal tabstop=4 |
    \ setlocal softtabstop=4 |
    \ setlocal shiftwidth=4 |
    \ setlocal textwidth=79 |
    \ setlocal autoindent |
    \ setlocal expandtab |
    \ setlocal fileformat=unix

" yml
" au BufReadPost *.yml set syntax=yaml
" au BufNewFile,BufRead *.yml,*.yaml, *.cmake, *.txt
"     \ setlocal tabstop=2 |
"     \ setlocal softtabstop=2 |
"     \ setlocal shiftwidth=2 |
"     \ setlocal textwidth=79 |
" 	\ setlocal colorcolumn=79 |
"     \ setlocal expandtab |
"     \ setlocal autoindent |
" 
" Assuming the objects are highlighted using the 'yamlBlockMappingKey' group:
autocmd FileType yaml highlight yamlBlockMappingKey guifg=#00FF00 ctermfg=Green
autocmd FileType yml highlight yamlBlockMappingKey guifg=#00FF00 ctermfg=Green
" vim -b : edit binary using xxd-format!
augroup Binary
  au!
  au BufReadPre  *.bin,*.pcap let &bin=1
  au BufReadPost *.bin,*.pcap if &bin | %!xxd
  au BufReadPost *.bin,*.pcap set ft=xxd | endif
  au BufWritePre *.bin,*.pcap if &bin | %!xxd -r
  au BufWritePre *.bin,*.pcap endif
  au BufWritePost *.bin,*.pcap if &bin | %!xxd
  au BufWritePost *.bin,*.pcap set nomod | endif
augroup END

" js, css , HTML, Markdown
au BufReadPost *.mak set syntax=html
au BufNewFile,BufRead *.md,*.js,*.json,*.html,*.svg,*.mako,*.css,*.vue,*.svelte
    \ setlocal tabstop=2 |
    \ setlocal softtabstop=2 |
    \ setlocal shiftwidth=2 |
    \ setlocal textwidth=79 |
	\ setlocal colorcolumn=79 |
    \ setlocal expandtab |
    \ setlocal autoindent |

" haskell
au BufRead,BufNewFile *.hs,*.cabal
    \ setlocal tabstop=2 |
    \ setlocal softtabstop=2 |
    \ setlocal shiftwidth=2 |
    \ setlocal textwidth=79 |
    \ setlocal autoindent |
    \ setlocal expandtab |
    \ setlocal fileformat=unix

" shell
au BufReadPost *.sh set syntax=bash
au BufNewFile,BufRead *.sh,*.sh
    \ setlocal tabstop=2 |
    \ setlocal softtabstop=2 |
    \ setlocal shiftwidth=2 |
    \ setlocal textwidth=79 |
	\ setlocal colorcolumn=79 |
    \ setlocal expandtab |
    \ setlocal autoindent |


let g:haskell_enable_quantification = 1   " to enable highlighting of `forall`
let g:haskell_enable_recursivedo = 1      " to enable highlighting of `mdo` and `rec`
let g:haskell_enable_arrowsyntax = 1      " to enable highlighting of `proc`
let g:haskell_enable_pattern_synonyms = 1 " to enable highlighting of `pattern`
let g:haskell_enable_typeroles = 1        " to enable highlighting of type roles
let g:haskell_enable_static_pointers = 1  " to enable highlighting of `static`
let g:haskell_backpack = 1                " to enable highlighting of backpack keywords
let g:haskell_classic_highlighting = 0

" Other (miscellaneous)
au BufRead,BufNewFile *.rst
    \ setlocal tabstop=4 |
    \ setlocal softtabstop=4 |
    \ setlocal shiftwidth=4 |
    \ setlocal textwidth=79 |
    \ setlocal expandtab |
    \ setlocal autoindent |
    \ setlocal fileformat=unix

" YouCompleteMe
" let g:ycm_autoclose_preview_window_after_completion=1
"map <leader>g  :YcmCompleter GoToDefinitionElseDeclaration<CR>

" ignore files in NERDTree
let NERDTreeIgnore = [
			\ '^data$', 
			\ '\.pyc$',
			\ '\~$', 
			\ '^__pycache__$', 
			\ '\.egg-info', 
			\ '^build$', 
			\ '^_build', 
			\ '^dist$', 
			\ '\.so$', 
			\ '\.o$', 
			\ '^obj',
			\ '^node_modules',
			\ '^package-lock.json',
			\ '\.gcno',
			\ '\.gcda',
			\ '\.gcov',
			\ '^dist-newstyle$',
			\ '^cabal.project.local$',
			\ ] 

autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | endif
let g:NERDTreeGitStatusShowIgnored = 1
let g:NERDTreeMinimalMenu=1

fun! NoseTestCurrentScope()
    " Find function under cursor
    let l:scope = ""
    let l:save = winsaveview()
    normal [[
    let l:class_matches = filter(matchlist(getline('.'), '\s*class \(\w*\)(.*'), 'v:val !=# ""')
    if len(l:class_matches) > 0
        let l:scope = l:class_matches[1]
    endif
    call winrestview(l:save)
    normal [m
    let l:func_matches = filter(matchlist(getline('.'), '\s*\(async\sdef|def\)\s\(test_[\w_]*\).*'), 'v:val !=# ""')
    if len(l:func_matches) > 1
        let l:scope = join([l:scope, l:func_matches[1]], '.')
    endif
    execute ':!nosetests -s --pudb %\:' . l:scope
    call winrestview(l:save)
endfun

let test#python#runner = 'pytest'


fun! PyTestCurrentScope()
    " Find function under cursor
    let l:scope = ""
    let l:save = winsaveview()
	for i in [1, 2, 3, 4, 5, 6, 7, 8, 9]
		normal [m
		let l:func_matches = matchlist(getline('.'), '\s*def \(test_\w*\)(.*')
		echo l:func_matches
        if len(l:func_matches) > 1
            let l:scope = l:func_matches[1]
			break
        endif
	endfor
	if len(l:scope) > 0	
		execute ':!pytest -vv ' . shellescape(@%, 1) . ' -k ' . l:scope
	endif
    call winrestview(l:save)
endfun

augroup python_test
    autocmd!
    autocmd Filetype python nnoremap <Leader>t :write<cr> :call PyTestCurrentScope()<CR>
augroup end

" Themes

"set termguicolors
colorscheme space-vim-dark
let g:space_vim_dark_background = 233
set background=dark
color space-vim-dark
"highlight Comment cterm=italic
"let g:solarized_termcolors=256
"let g:spacevim_enable_guicolors=0
"color dracula

" ColorColumn Color
hi ColorColumn guibg=#262626 ctermbg=235
hi Search cterm=NONE ctermfg=white ctermbg=darkblue

" Highlight cursor line underneath the cursor horizontally.
set cursorline

" Highlight cursor line underneath the cursor vertically.
set cursorcolumn

" Enable auto completion menu after pressing TAB.
set wildmenu

" Make wildmenu behave like similar to Bash completion.
set wildmode=list:longest


highlight CursorLineNr ctermbg=0 ctermfg=6

" python-mode
" let g:pymode_run = 1
" let g:pymode_run_bind = '<leader>r'
" let g:pymode_breakpoint = 1
" let g:pymode_breakpoint_bind = '<leader>b'
let g:pymode_breakpoint_cmd = 'from pudb import set_trace; set_trace()'
let g:pymode_python = 'python3'
let g:pymode_virtualenv = 1
let g:pymode_virtualenv_path = $HOME . '/.vim/pyenv'

" Bash aliases
"set shellcmdflag=-ic
let $BASH_ENV = "~/.bash_aliases"


" Python code comment
vnoremap <silent> # :s/^/#/<cr>:noh<cr>
vnoremap <silent> -# :s/^#//<cr>:noh<cr>

nnoremap <Leader>c :HighlightCoverage<CR>
nnoremap <Leader>d :HighlightCoverageOff<CR>
autocmd FileType python nnoremap <buffer> <F9> :write<cr> :exec '!python3' shellescape(@%, 1)<cr>
autocmd FileType python nnoremap <buffer> <F8> :write<cr> :exec '!pytest -vvv' shellescape(@%, 1)<cr>
autocmd FileType python nnoremap <buffer> <F7> :write<cr> :exec '!P=`basename $(pwd)`; py.test --cov=$P tests'<cr>
autocmd FileType python nnoremap <buffer> <F10> :write<cr> :exec '!P=`basename $(pwd)`; py.test --cov=$P 'shellescape(@%, 1)<cr>
"autocmd FileType python nnoremap <buffer> <F7> :write<cr> :exec '!P=`basename $(pwd)`; py.test --cov=$P $P/tests'<cr>
"noremap <F10> :write<cr> :exec '!coverage run --source $(python3 -c "from setuptools import find_packages; print(find_packages()[0])") $(which nosetests)'<cr>

" autocmd FileType python,*.pyx nnoremap <Leader>B :exec '!python setup.py build_ext --force --inplace --define=CYTHON_TRACE'<cr>
nnoremap <Leader>B  :write<cr> :exec '!python3 setup.py build_ext --force --inplace --define=CYTHON_TRACE'<cr>
nnoremap <Leader>m  :write<cr> :exec '!make'<cr>
nnoremap <Leader>f  :write<cr> :exec '!make flash'<cr>
autocmd FileType python,*.pyx nnoremap <Leader>l :PymodeLintAuto <cr>
autocmd Filetype python,*.pyx nnoremap <Leader>8 :Autopep8 <cr>

"let g:auto_save = 1  " enable AutoSave on Vim startup
"let g:auto_save_no_updatetime = 1  " do not change the 'updatetime' option
"let g:auto_save_in_insert_mode = 0  " do not save while in insert mode
"autocmd InsertLeave * write

set t_Co=256

" Double o within 1 second to insert new line and back to normal mode.
nmap oo o<Esc>

" Added sopport for HTML (and other languages) matching tags with %
runtime macros/matchit.vim

" Press Leader+Space to turn off highlighting and clear any message already displayed.
nnoremap <Leader><Space> :nohlsearch<Bar>:echo<CR>

" PEP8
let g:autopep8_max_line_length=79

" NERDTree costomization
" Quite NerdTree when closing the last buffer
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
let NERDTreeMinimalUI = 1
let NERDTreeDirArrows = 1
let NERDTreeAutoDeleteBuffer = 1
map <C-n> :NERDTreeToggle<CR>
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
let g:NERDTreeWinSize=22
let NERDTreeMapOpenSplit = 'v'
let NERDTreeMapOpenVSplit = 's'

" Vim slow scrolling
set lazyredraw
set synmaxcol=160
syntax sync minlines=256

" Paste multiple times
xnoremap p pgvy

" Open new tab
nnoremap <C-t> <esc>:tabnew<CR>

" Close current tab
nnoremap <C-y> <esc>:tabclose<CR>

" Disable F1 and map it to esc
map <F1> <Esc>
imap <F1> <Esc>


" Saved macros
let @d = '0f/xxxiCHK("␛��af*hxxxa");␛��a'
let @c = '0fC5xi/* ␛lf"d$a */␛��a'
" Using local config. Uncomment line below. 
"source ~/.vimrc-local


" You can use the 'formatoptions' option  to influence how Vim formats text.
" 'formatoptions' is a string that can contain any of the letters below.  The
" default setting is "tcq".  You can separate the option letters with commas for
" readability.
" 
" letter  meaning when present in 'formatoptions'
" 
" t       Auto-wrap text using textwidth
" c       Auto-wrap comments using textwidth, inserting the current comment
"         leader automatically.
" r       Automatically insert the current comment leader after hitting
"         <Enter> in Insert mode.
" o       Automatically insert the current comment leader after hitting 'o' or
"         'O' in Normal mode.
" https://stackoverflow.com/questions/6076592/vim-set-formatoptions-being-lost
" autocmd BufNewFile,BufRead * setlocal fo-=t fo-=c fo-=-r fo-=o fo-=q fo-=l
" set fo-=t fo-=c fo-=-r fo-=o fo-=q fo-=l

" https://stackoverflow.com/questions/19320747/prevent-vim-from-indenting-line-when-typing-a-colon-in-python
" autocmd FileType python setlocal indentkeys-=<:>
" autocmd FileType python setlocal indentkeys-=:

let g:pymode_lint = 0

" Svelte
let g:vim_svelte_plugin_use_sass=1
let g:vim_svelte_plugin_has_init_indent=1
let g:vim_svelte_plugin_load_full_syntax=1 

" Prettier Settings
let g:prettier#quickfix_enabled = 0
let g:prettier#autoformat_require_pragma = 0
au BufWritePre *.css,*.svelte,*.pcss,*.html,*.ts,*.js,*.json PrettierAsync

" Remove trailing whitespaces
fun! TrimWhitespace()
    let l:save = winsaveview()
    keeppatterns %s/\s\+$//e
    call winrestview(l:save)
endfun
autocmd BufWritePre *.c,*.ino,*.cpp,*.h,*.py call TrimWhitespace()


" Editor command aliases:
" cnoreabbrev <expr> W ((getcmdtype() is# ':' && getcmdline() is# 'W')?('w'):('W'))
fun! SetupCommandAlias(from, to)
  exec 'cnoreabbrev <expr> '.a:from
        \ .' ((getcmdtype() is# ":" && getcmdline() is# "'.a:from.'")'
        \ .'? ("'.a:to.'") : ("'.a:from.'"))'
endfun
call SetupCommandAlias("W","w")
call SetupCommandAlias("Wa","wa")

