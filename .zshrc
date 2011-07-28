# binds

eval "$(sed -n 's/^"/bindkey "/; s/history-search/history-beginning-search/; s/: / /p;' ~/.inputrc)"

# history

HISTSIZE=8192
SAVEHIST=8192
HISTFILE=~/.zhistory

setopt append_history
setopt hist_find_no_dups
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt hist_no_functions
setopt hist_no_store
setopt hist_reduce_blanks
setopt hist_save_no_dups
setopt inc_append_history
setopt share_history

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
  xterm*|rxvt*)
    function title() { print -Pn "\e]0;%n@%m: ${PWD/#$HOME/~}\a" }
    add-zsh-hook precmd title
  ;;
esac

PROMPT='
%F{200}%n%f at %F{202}%m%f in %F{220}${PWD/#$HOME/~}%f${vcs_info_msg_0_}
$(prompt) '
