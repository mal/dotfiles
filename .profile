# run dotfile updater
$HOME/.dotfiles/install.sh update

# add private bin to path
if [ -d "$HOME/bin" ]; then
    PATH="$HOME/bin:$PATH"
fi

# set editor
VISUAL=vim
EDITOR=vim

if [ -f "$HOME/.localrc" ]; then
    source $HOME/.localrc
fi
