" abandon vi
set nocompatible

" configure vundle
filetype off
set rtp+=~/.vim/bundle/vundle/
call vundle#rc()

" bundles ahoy!
Bundle 'evanmiller/nginx-vim-syntax'
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
set number
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
nmap <silent> <leader>S :%s/\s\+$//<cr>

" retab
nmap <silent> <leader>r :set et<cr>:%s/\v%(^\s*)@<=\t/    /<cr>

" inverse retab
nmap <silent> <leader>R :set noet<cr>:%s/\v%(^\s*)@<= {4}/\t/<cr>

" edit/reload vimrc
nmap <silent> <leader>ve <c-w>s<c-w>j<c-w>L:e $MYVIMRC<cr>
nmap <silent> <leader>vr :so $MYVIMRC<cr>

" easy commenting
func s:comments(pattern)
  exe 'vnoremap <buffer> / :s/^/' . a:pattern . ' /<cr>:set nohlsearch<cr>gv'
  exe 'vnoremap <buffer> ? :s/^' . a:pattern . '\s\?//<cr>:set nohlsearch<cr>gv'
endf

" default comments
call s:comments('#')

" filetype comments
au filetype javascript,java,cpp call s:comments('\/\/')
au filetype sql,plsql call s:comments('--')
au filetype vim call s:comments('"')

" filetype idents
au filetype coffee,plsql,ruby,sh,sql,vim set sw=2 sts=2 ts=2
au filetype make set sw=8 sts=8 ts=8
