# binds

bindkey '\e[1~' beginning-of-line
bindkey '\e[4~' end-of-line

bindkey '\e[5~' history-beginning-search-backward
bindkey '\e[6~' history-beginning-search-forward

bindkey \^U backward-kill-line

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

autoload -Uz vcs_info

zstyle ':vcs_info:*' enable git svn
zstyle ':vcs_info:*' stagedstr '%F{28}●'
zstyle ':vcs_info:*' unstagedstr '%F{11}●'
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' formats ' on %F{61}%b%c%u%f'
zstyle ':vcs_info:(sv[nk]|bzr):*' branchformat '%b%f at %F{59}%r'

setopt prompt_subst

function prompt()
{
    git branch > /dev/null 2> /dev/null && echo '±' && return
    echo '%(0#.#.$)'
}

function precmd()
{
    vcs_info
}

PROMPT='
%F{200}%n%f at %F{202}%m%f in %F{220}${PWD/#$HOME/~}%f${vcs_info_msg_0_}
$(prompt) '

# aliases

alias ls='ls --color=always'
alias ll='ls -l'
alias la='ls -al'