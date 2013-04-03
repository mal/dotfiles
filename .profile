# run dotfile updater
bash $HOME/.dotfiles/manager.sh update

# add private bin to path
if [ -d "$HOME/bin" ]; then
    export PATH="$HOME/bin:$PATH"
fi

# set editor
export VISUAL=vim
export EDITOR=vim
