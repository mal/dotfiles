# set 256 colour terminal
export TERM=xterm-256color

# run dotfile updater
$HOME/.dotfiles/manager.sh update

# add private bin to path
if [ -d "$HOME/bin" ]; then
    export PATH="$HOME/bin:$PATH"
fi

# set editor
export VISUAL=vim
export EDITOR=vim
