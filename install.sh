#!/usr/bin/env bash

########################################
# This is the list of conf files that we
# want to automagically link after
# checking out to the remote machine
########################################

# 'remove' means to remove the files so they can be linked
# 'cleanup' means to remove all the files created by this script
remove="$1"

dotfiles_loc="$HOME/.dotfiles"
excluded=(
    .svn
    .git
    .DS_Store
    .
    ..
    .AppleDouble
)
# make sure the dotfiles are only rwx by the owner
chmod 700 $dotfiles_loc
# make sure my home dir is secured
chmod 700 $HOME

notExcluded() {
    # check that the value exists
    if [ -z "$1" ]; then
        return
    fi

    for i in ${excluded[@]}
    do
        if [ $i == $1 ]; then
            # the item exists
            return 1
        fi
    done
    # it did not exist
    return 0
}

linkDotfile() {
    dotfile="$1"
    to_create="$2"
    actual_dotfile="$3"
    # clean up if requested
    if [ "$remove" = "remove" ] || [ "$remove" = "cleanup" ]; then
        if [ -e "$to_create" ]; then
            rm "$to_create"
            echo "Deleted $to_create"
        fi
    else
        # symlink the conf file
        if [ ! -e "$to_create" ]; then
            echo "linking $dotfile"
            ln -s $actual_dotfile $to_create
        fi
        # warn the user that an existing file is in the way
        if [ ! -h "$to_create" -a -e "$to_create" ]; then
            echo "Remove $to_create so that it can be linked"
        fi
    fi
}

updateDotfiles() {
    local vcs_update
    cd $dotfiles_loc
    if [ -f install.log ]; then
        local previous=$(($(stat install.log -c %Y) / 86400))
        local today=$(($(date +%s) / 86400))
        [ $today -le $previous ] && return 1;
    fi

    if [ -d $dotfiles_loc/.git ] && [ `which git` ]; then
        vcs_update="git pull"
    elif [ -d $dotfiles_loc/.svn ] && [ `which svn` ]; then
        vcs_update="svn up"
    fi
    echo $(date "+%a %b %0d %Y %H:%I:%S %Z"):  $($vcs_update) >> install.log
}

# Catch update action, and update the dotfiles from origin
# -----------------------------------------------------------------
if [ "$remove" = "update" ]; then
    if ! updateDotfiles; then
        exit 0
    fi
fi

# Links all the dotfiles from the .dotfiles directory
# -----------------------------------------------------------------
for actual_dotfile in $dotfiles_loc/.*
    do
        dotfile=$(echo $actual_dotfile | awk -F"$dotfiles_loc/" '{print $2}')
        # ignore certain directories
        if notExcluded $dotfile; then
            to_create="$HOME/$dotfile"
            linkDotfile $dotfile $to_create $actual_dotfile
        fi
    done

# allow for zsh shell using the same .profile
# -----------------------------------------------------------------
if [ `which zsh` ]; then
    actual_dotfile="$dotfiles_loc/.profile"
    dotfile=".zprofile"
    to_create="$HOME/$dotfile"
    linkDotfile $dotfile $to_create $actual_dotfile
fi

# take care of the .subversion/config file
# -----------------------------------------------------------------
if [ -d $HOME/.subversion ]; then
    actual_dotfile="$dotfiles_loc/config"
    dotfile="config"
    to_create="$HOME/.subversion/$dotfile"
    # actually create/remove the link
    linkDotfile $dotfile $to_create $actual_dotfile
fi

# NOTE: None of these files are under version control...
# -----------------------------------------------------------------
if [ ! "$remove" = "remove" ]; then

    # warn the user what is about to happen
    if [ "$remove" = "cleanup" ]; then
        echo '
******************************************
These files are not under version control
Deleting them will remove them immediately
******************************************
'
    fi

    # touch extra files needed by the confs
    # -------------------------------------------------------------
    touch_me=(
    )
    for to_touch in "${touch_me[@]}"
        do
            TOUCH_FILE="$HOME/$to_touch"
            # if we are cleaning up offer to delete these files
            if [ "$remove" = "cleanup" ]; then
                if [ -e "$TOUCH_FILE" ]; then
                    echo -n "Are you sure you want to delete $TOUCH_FILE? [n]: "
                    read REMOVE_FILE
                    if [ "$REMOVE_FILE" = "y" ]; then
                      rm "$TOUCH_FILE"
                      echo "Deleted $TOUCH_FILE"
                    fi
                fi
            # touch the files if they don't exist
            elif [ ! -e "$TOUCH_FILE" ]; then
                echo "touching $TOUCH_FILE"
                touch "$TOUCH_FILE"
                chmod 600 "$TOUCH_FILE"
            fi
        done

    DIRS_TO_MAKE=(
        "$HOME"/bin
        "$HOME"/.backup
        "$HOME"/.backup/vim/swap
        "$HOME"/.backup/vim/temp
        "$HOME"/.backup/vim/undo
    )

    # create the $DIRS_TO_MAKE
    # -------------------------------------------------------------
    processDotDir() {
        local dot_directory
        dot_directory=$1
        # if we are cleaning up, let's remove the dir
        if [ "$remove" = "cleanup" ]; then
            if [ -d "$dot_directory" ]; then
                echo -n "Are you sure you want to delete $dot_directory? [n]: "
                read REMOVE_DIR
                if [ "$REMOVE_DIR" = "y" ]; then
                    rm -rf "$dot_directory"
                    echo "Deleted $dot_directory"
                fi
            fi
        # if the directory doesn't exist, let's create it
        elif [[ ! -d "$dot_directory" ]] && [[ ! -a "$dot_directory" ]]; then
            mkdir -p "$dot_directory" && echo "created a $dot_directory directory"
            chmod 700 "$dot_directory"
        elif [[ ! -d "$dot_directory" ]] && [[ -a "$dot_directory" ]]; then
            echo "something in the way of $dot_directory being created"
        fi
    }

    for dir in "${DIRS_TO_MAKE[@]}"
        do
            processDotDir $dir
        done
fi
