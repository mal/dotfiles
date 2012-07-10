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
Bundle 'tpope/vim-surround'

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
set colorcolumn=85
set cursorline
set directory=~/.cache/swap,.,/tmp
set encoding=utf-8
set expandtab
set fileformat=unix
set formatoptions=qrn1
set gdefault
set hidden
set history=1000
set hlsearch
set ignorecase
set incsearch
set lazyredraw
set listchars=tab:>-,trail:·,eol:$
set nomodeline
set relativenumber
set ruler
set scrolloff=3
set shell=sh
set shiftwidth=4
set showcmd
set smartcase
set smartindent
set softtabstop=4
set tabstop=4
set textwidth=79
set ttyfast
set undodir=~/.cache/undo
set undofile
set wildmenu
set wildmode=list:longest,full
set wrap

" mousey is here
if has('mouse')
    set mouse=a
endif

" pretty colors
syntax on
sil! color jellybeans

" use relative line numbers in command mode
au insertenter * :set number
au insertleave * :set relativenumber

" take care of forgetting to use sudo with :w!!
cmap w!! w !sudo tee % > /dev/null

" magic search
nnoremap / /\v
vnoremap / /\v

" bracket navigation
nnoremap <tab> %
vnoremap <tab> %

" avoid shift key
nnoremap ; :

" abort insert mode
inoremap jj <ESC>

" easy tabbing in visual mode
vmap <tab> >gv
vmap <s-tab> <gv
vnoremap < <gv
vnoremap > >gv

" open some windows
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" time to put up or shut up
inoremap <up> <nop>
inoremap <down> <nop>
inoremap <left> <nop>
inoremap <right> <nop>
nnoremap <up> <nop>
nnoremap <down> <nop>
nnoremap <left> <nop>
nnoremap <right> <nop>
vnoremap <up> <nop>
vnoremap <down> <nop>
vnoremap <left> <nop>
vnoremap <right> <nop>
nnoremap j gj
nnoremap k gk

" take me to your leader
let mapleader = ','

" deal with pesky windows eol-style
noremap <leader>m mmHmt:%s/<c-v><cr>//ge<cr>

" hide search reslts
nmap <silent> <leader>/ :nohlsearch<cr>

" show whitespace
nmap <silent> <leader>s :set list!<cr>

" nuke whitespace
nmap <silent> <leader>S :%s/\s\+$//g<cr>

" edit/reload vimrc
nmap <silent> <leader>ev <c-w>s<c-w>j<c-w>L:e $MYVIMRC<cr>
nmap <silent> <leader>rv :so $MYVIMRC<cr>

" easy commenting
au filetype php,javascript,java,cpp vnoremap <buffer> / :s/^/\/\/ /<cr>:set nohlsearch<cr>gv
au filetype php,javascript,java,cpp vnoremap <buffer> ? :s/^\s*\/\/ \?//<cr>:set nohlsearch<cr>gv
au filetype sql,plsql               vnoremap <buffer> / :s/^/-- /<cr>:set nohlsearch<cr>gv
au filetype sql,plsql               vnoremap <buffer> ? :s/^--\s\?//<cr>:set nohlsearch<cr>gv
au filetype sql,plsql               set shiftwidth=2 softtabstop=2 tabstop=2
