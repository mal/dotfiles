"
" Paste Magic plugin for adding paste mode to the insert key
" Maintainer: Mal Graty <madmalibu@gmail.com>
" Version: Vim 7 (may work with lower Vim versions, but not tested)
" URL: http://github.com/mal/vim-paste-magic
"
" Only do this when not done yet for this buffer
if exists("b:loaded_paste_magic_plugin")
    finish
endif
let b:loaded_paste_magic_plugin = 1

" paste magic, add paste mode to the insert key
fu s:map()
    map! <insert> <c-o>:call <SID>toggle('m')<cr>
endf

" manage toggling of paste and insert modes
fu s:toggle(mode)
    if a:mode == 'a'
        if v:insertmode == 'r'
            iunmap <insert>
        else
            call <SID>map()
        endif
    endif
    if a:mode != 'a' || &paste
        set invpaste
        set invnumber
    endif
    set paste?
endf

" map/hooks for paste magic
call <SID>map()
au insertchange * call <SID>toggle('a')
