# run dotfile updater
$HOME/.dotfiles/manager.sh update

# add private bin to path
if [ -d "$HOME/bin" ]; then
    PATH="$HOME/bin:$PATH"
fi

# set editor
VISUAL=vim
EDITOR=vim

if [ -f "$HOME/.aliases" ]; then
    source $HOME/.aliases
fi

if [ -f "$HOME/.localrc" ]; then
    source $HOME/.localrc
fi
