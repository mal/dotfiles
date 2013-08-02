# run dotfile updater
bash $HOME/.dotfiles/manager.sh update

# add private bin to path
if [ -d "$HOME/bin" ]; then
    export PATH="$HOME/bin:$PATH"
fi

# set editor
export VISUAL=vim
export EDITOR=vim

. ~/.pre-exec

# called before each command and starts stopwatch
function preexec () {
    read -p "Are you sure you want to run $BASH_COMMAND?" -n 1
    if [[ ! $REPLY =~ ^[Yy]$ ]]
    then
        false
    fi
}

preexec_install