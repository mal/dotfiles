" abandon vi
set nocompatible

" make windows use the unix path
if has('win32') || has('win64')
  set rtp=$HOME/.vim,$VIM/vimfiles,$VIMRUNTIME,$VIM/vimfiles/after,$HOME/.vim/after
  set nowritebackup
endif

" configure vundle
filetype off
set rtp+=~/.vim/bundle/vundle/
call vundle#rc()

" bundles ahoy!
Bundle 'evanmiller/nginx-vim-syntax'
Bundle 'gmarik/vundle'
Bundle 'guns/vim-clojure-static'
Bundle 'kchmck/vim-coffee-script'
Bundle 'mal/vim-pastemode'
Bundle 'mmalecki/vim-node.js'
Bundle 'nanotech/jellybeans.vim'
Bundle 'pangloss/vim-javascript'
Bundle 'tpope/vim-markdown'
Bundle 'tpope/vim-repeat'
Bundle 'tpope/vim-surround'
Bundle 'zaiste/tmux.vim'

" main options
set autoindent
set background=dark
set backspace=indent,eol,start
set backup
set backupdir=~/.cache/temp,.,/tmp
set backupskip=/tmp/*,$TMPDIR/*,$TMP/*,$TEMP/*
set clipboard=unnamedplus,unnamed
set colorcolumn=80
set cursorline
set directory=~/.cache/swap,.,/tmp
set encoding=utf-8
set expandtab
set fileformats=unix,dos
set formatoptions=qrn1
set gdefault
set hidden
set history=1000
set hlsearch
set ignorecase
set incsearch
set lazyredraw
set listchars=eol:$,nbsp:¬,tab:>-,trail:·
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
set splitbelow
set splitright
set tabstop=4
set textwidth=72
set ttyfast
set ttymouse=xterm2
set undodir=~/.cache/undo,.,/tmp
set undofile
set wildmenu
set wildmode=list:longest,full
set wrap

" gui options
set gfn=monaco:h12,consolas:h13
set go=iMr

" mousey is here
if has('mouse')
  set mouse=a
endif

" pretty colors
syntax on
sil! color jellybeans

" take care of forgetting to use sudo with :w!!
cmap w!! sil exec 'w !sudo tee ' . shellescape(@%, 1) . ' > /dev/null' \| sil e!

" search history
cmap <pageup> <up>
cmap <pagedown> <down>

" bracket navigation
nnoremap <tab> %
vnoremap <tab> %

" avoid shift key
nnoremap ; :

" abort insert mode
inoremap jj <ESC>

" easy tabbing in visual mode
vmap <tab> >
vmap <s-tab> <
vnoremap < <gv
vnoremap > >gv

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
let mapleader = '\'

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
func! s:comments(pattern)
  exe 'vnoremap <buffer> / ' .
    \ ':s/^/' . a:pattern . ' /<cr>:set nohlsearch<cr>gv'
  exe 'vnoremap <buffer> ? ' .
    \ ':s/^' . a:pattern . '\s\?//<cr>:set nohlsearch<cr>gv'
endf

" default comments
call s:comments('#')

" filetype comments
au filetype autohotkey,clojure
  \ call s:comments(';')
au filetype c,cpp,java,javascript,scss
  \ call s:comments('\/\/')
au filetype plsql,sql
  \ call s:comments('--')
au filetype vim
  \ call s:comments('"')

" filetype tweaks
au filetype autohotkey,clojure,coffee,plsql,ruby,scss,sh,sql,vim
  \ setl sw=2 sts=2 ts=2
au filetype make
  \ setl noet sw=8 sts=8 ts=8
au filetype markdown
  \ setl tw=79
