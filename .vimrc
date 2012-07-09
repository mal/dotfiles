" abandon vi
set nocompatible

" configure vundle
filetype off
set rtp+=~/.vim/bundle/vundle/
call vundle#rc()

" bundles ahoy!
Bundle 'gmarik/vundle'
Bundle 'kchmck/vim-coffee-script'
Bundle 'mal/vim-pastemode'
Bundle 'nanotech/jellybeans.vim'
Bundle 'pangloss/vim-javascript'

" make windows use the unix path
if has('win32') || has('win64')
  set runtimepath=$HOME/.vim,$VIM/vimfiles,$VIMRUNTIME,$VIM/vimfiles/after,$HOME/.vim/after
endif

" main options
set autoindent
set background=dark
set backspace=indent,eol,start
set backup
set backupdir=~/.cache/temp,.,/tmp
set backupskip=/tmp/*,$TMPDIR/*,$TMP/*,$TEMP/*
set binary
set cursorline
set directory=~/.cache/swap,.,/tmp
set encoding=utf-8
set expandtab
set ttyfast
set fileformat=unix
set hidden
set history=1000
set hlsearch
set incsearch
set ignorecase
set lazyredraw
set listchars=tab:>-,trail:·,eol:$
set nomodeline
set relativenumber
set ruler
set shell=sh
set shiftwidth=4
set showcmd
set smartcase
set smartindent
set softtabstop=4
set tabstop=4

" fancy undoness ready for natty
if v:version >= 703
    set undofile
    set undodir=~/.cache/undo
endif

" mousey is here
if has('mouse')
    set mouse=a
endif

" pretty colors
syntax on
sil! color jellybeans

" set leader
let mapleader = ","

" take care of forgetting to use sudo with :w!!
cmap w!! w !sudo tee % > /dev/null

" use relative line numbers in command mode
au insertenter * :set number
au insertleave * :set relativenumber

" show whitespace
nmap <silent> <leader>s :set list!<cr>
" hide search results
nmap <silent> <leader>/ :nohlsearch<cr>
" edit/reload vimrc
nmap <silent> <leader>ev <c-w>s<c-w>j<c-w>L:e $MYVIMRC<cr>
nmap <silent> <leader>rv :so $MYVIMRC<cr>
" avoid shift key
nnoremap ; :
" deal with pesky windows eol-style
noremap <leader>m mmHmt:%s/<c-v><cr>//ge<cr>

" easy tabbing in visual mode
vmap <tab> >gv
vmap <s-tab> <gv
vnoremap < <gv
vnoremap > >gv

" abide pep20
au filetype python set tabstop=4 textwidth=79

" easy commenting
au filetype php,javascript,java,cpp vnoremap <buffer> / :s/^/\/\/ /<cr>:set nohlsearch<cr>gv
au filetype php,javascript,java,cpp vnoremap <buffer> ? :s/^\s*\/\/ \?//<cr>:set nohlsearch<cr>gv
au filetype sql,plsql               vnoremap <buffer> / :s/^/-- /<cr>:set nohlsearch<cr>gv
au filetype sql,plsql               vnoremap <buffer> ? :s/^--\s\?//<cr>:set nohlsearch<cr>gv
au filetype sql,plsql               set shiftwidth=2 softtabstop=2 tabstop=2
