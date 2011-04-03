" abandon vi
set nocompatible

" make windows use the unix path
if has('win32') || has('win64')
  set runtimepath=$HOME/.vim,$VIM/vimfiles,$VIMRUNTIME,$VIM/vimfiles/after,$HOME/.vim/after
endif

" main options
set autoindent
set background=dark
set backspace=indent,eol,start
set backup
set backupdir=~/.backup/vim/temp,.,/tmp
set backupskip=/tmp/*,$TMPDIR/*,$TMP/*,$TEMP/*
set binary
set cursorline
set directory=~/.backup/vim/swap,.,/tmp
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
set number
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
    set undodir=~/.backup/vim/undo
endif

" mousey is here
if has('mouse')
    set mouse=a
endif

" pretty colors
syntax on
color jellybeans

" set leader
let mapleader = ","

" paste magic, add paste mode to the insert key
fu InsertMap()
    map! <insert> <c-o>:call InsertSwitch('m')<cr>
endf

" manage toggling of paste and insert modes
fu InsertSwitch(mode)
    if a:mode == 'a'
        if v:insertmode == 'r'
            iunmap <insert>
        else
            call InsertMap()
        endif
    endif
    if a:mode != 'a' || &paste
        set invpaste
        set invnumber
    endif
    set paste?
endf

" map/hooks for paste magic
call InsertMap()
au insertchange * call InsertSwitch('a')

" setup insert key hook
map <insert> :call InsertSwitch('m')<cr>
" deal with pesky windows eol-style
noremap <leader>m mmHmt:%s/<c-v><cr>//ge<cr>'tzt'm:echo substitute(system("svn propset svn:eol-style native " . shellescape(expand('%'))), "\\n", "", "g")<cr>

" take care of forgetting to use sudo with :w!!
cmap w!! w !sudo tee % > /dev/null

" show whitespace
nmap <silent> <leader>s :set nolist!<CR>
" edit vimrc
nnoremap <leader>v <C-w>s<C-w>j<C-w>L:e ~/.vimrc<cr>

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
au filetype sql                     vnoremap <buffer> / :s/^/-- /<cr>:set nohlsearch<cr>gv
au filetype sql                     vnoremap <buffer> ? :s/^--\s\?//<cr>:set nohlsearch<cr>gv
