# history

HISTSIZE=16384
SAVEHIST=16384
HISTFILE=~/.zhistory

setopt append_history
setopt completeinword
setopt hist_find_no_dups
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt hist_no_functions
setopt hist_no_store
setopt hist_reduce_blanks
setopt hist_save_no_dups
setopt inc_append_history
setopt interactivecomments
setopt share_history

# vi mode

setopt vi
bindkey -v

zle -A .backward-delete-char vi-backward-delete-char
zle -A .backward-kill-word vi-backward-kill-word

# binds

zle -A .history-beginning-search-backward history-search-backward
zle -A .history-beginning-search-forward history-search-forward

eval "$(sed -n 's/^"/bindkey "/; s/: / /; /^bindkey/p' ~/.inputrc)"

# prompt

autoload -Uz promptinit vcs_info
promptinit

zstyle ':vcs_info:*' enable git svn
zstyle ':vcs_info:*' stagedstr '%F{28}●'
zstyle ':vcs_info:*' unstagedstr '%F{11}●'
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' formats ' on %F{61}%b%c%u%f'
zstyle ':vcs_info:*' actionformats ' on %F{61}%b%c%u%f op %F{59}%a%f'
zstyle ':vcs_info:(sv[nk]|bzr):*' branchformat '%b%f at %F{59}%r'

setopt prompt_subst

function prompt()
{
    git branch > /dev/null 2> /dev/null && echo '±' && return
    echo '%(0#.#.$)'
}

add-zsh-hook precmd vcs_info

case $TERM in
  putty*|rxvt*|xterm*)
    function title() { print -Pn "\e]0;%n@%m: ${PWD/#$HOME/~}\a" }
    add-zsh-hook precmd title
  ;;
esac

PROMPT_USER_COLOUR=200
PROMPT_HOST_COLOUR=202
PROMPT_PATH_COLOUR=220

PROMPT='
%F{$PROMPT_USER_COLOUR}%n%f at %F{$PROMPT_HOST_COLOUR}%m%f in %F{$PROMPT_PATH_COLOUR}${PWD/#$HOME/~}%f${vcs_info_msg_0_}
$(prompt) '

# common
. $HOME/.commonrc
