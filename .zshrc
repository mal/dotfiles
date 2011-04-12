autoload -Uz vcs_info

zstyle ':vcs_info:*' enable git svn
zstyle ':vcs_info:*' stagedstr '%F{28}●'
zstyle ':vcs_info:*' unstagedstr '%F{11}●'
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' formats ' on %F{61}%b%c%u%f'
zstyle ':vcs_info:(sv[nk]|bzr):*' branchformat "%b%f at %F{59}%r"ls 

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