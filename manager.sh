#! /usr/bin/env bash

# function logic
##########################################################################

extra()
{
    # name parameters
    local type=$1
    local path=$2

    # build state; exists (0), conflict (1), missing (2)
    local state=$(( $([ -e "$path" ]; echo $?) + $([ "$type" = 'file' -a -f "$path" -o "$type" = 'dir' -a -d "$path" ]; echo $?) ))

    # build readable name
    local path_r="$(format "$path")"

    # log conflicts
    if [ $state -eq 1 ]
    then
        log error 'conflict' "$path_r"
        return 1
    fi

    case "$command" in
        clean)
            # log missing
            if [ $state -eq 2 ]
            then
                log debug 'missing' "$path_r"
                return
            fi

            # ask user about deletions
            if [ $interact -eq 1 ]
            then
                log user 'remove' "$path_r? [n]: " 1>&2
                read -n1 answer
                echo -en "\r\033[K" 1>&2
                if [ "$answer" != 'y' ]
                then
                    log warning 'ignored' "$path_r"
                    return
                fi
            fi

            # do deletions
            if [ "$type" = 'file' ]
            then
                rm "$path"
            else
                rm -rf "$path"
            fi

            # log it
            log notice 'removed' "$path_r"
            ;;
        install)
            # log pre-existing
            if [ $state -eq 0 ]
            then
                log debug 'skipped' "$path_r"
                return
            fi

            # do creations
            if [ "$type" = 'file' ]
            then
                touch "$path"
                chmod 600 "$path"
            else
                mkdir -p "$path"
                chmod 700 "$path"
            fi

            # log it
            log notice 'created' "$path_r"
            ;;
    esac
}

format()
{
    echo "'${1/$HOME/~}'"
}

include()
{
    if [ -z "$1" ]
    then
        return
    fi
    for item in ${exclude[@]}
    do
        if [ "$item" = "$1" ]
        then
            return 1
        fi
    done
    return 0
}

link()
{
    # name parameters
    local source=$1
    local target=$2

    # get source filename
    local file="$(basename $source)"

    # set name when not provided
    if [ -d "$target" -a ! -h "$target" ]
    then
        local target="$target/$file"
    fi

    # build readable names
    local target_r="$(format "$target")"

    # log excluded
    if ! include $file
    then
        log debug 'excluded' "$target_r"
        return 1
    fi

    # build state; linked (0), conflict (1), missing (2)
    local state=$(( $([ -e "$target" ]; echo $?) + $([ "$target" -ef "$source" ]; echo $?) ))

    # log conflicts
    if [ $state -eq 1 ]
    then
        log error 'conflict' "$target_r"
        return
    fi

    case "$command" in
        install)
            # log pre-existing
            if [ $state -eq 0 ]
            then
                log debug 'skipped' "$target_r"
                return
            fi

            # do linking
            ln -s "$source" "$target"

            # log it
            log notice 'linked' "$target_r"
            ;;
        remove)
            # log missing
            if [ $state -eq 2 ]
            then
                log debug 'missing' "$target_r"
                return
            fi

            # do unlinking
            rm "$target"

            # log it
            log notice 'unlinked' "$target_r"
            ;;
    esac
}

log()
{
    local nl="\n"

    # convert type to flag, abort if no type
    case "$1" in
        user)
            local flag=0
            local nl=
            ;;
        error)
            local flag=1
            local colour="1;31"
            ;;
        warning)
            local flag=2
            local colour="1;35"
            ;;
        notice)
            local flag=4
            local colour="1;32"
            ;;
        debug)
            local flag=8
            local colour="1;34"
            ;;
        ?)
            return
            ;;
    esac

    # abort due to too few args or not user and flag/verbosity mismatch
    if [ $# -lt 2 -o $flag -ne 0 -a $(($flag & $verbosity)) -eq 0 ]
    then
        return
    fi

    local action=$2
    if [ "$action" = '-' ]
    then
        local action=$1
    fi
    shift 2

    printf "\033[${colour}m%-10s\033[m%s$nl" "$action:" "$*"
}

pull()
{
    # cache last edit of this script
    local before=$(stat "$script" -c %Y)

    # note any local changes that get stashed
    local stashed=0
    if git stash | grep -iq '^saved'
    then
        local stashed=1
        log debug 'saved' 'local changes'
    fi

    # pull from remote, capture first line
    local line=$(git pull 2> /dev/null | cat | head -n1)

    if grep -iq '^updating' <<< $line
    then
        log notice 'pulled' "${line#* }"
    else
        log notice 'aborted' "$(echo ${line%.} | tr A-Z a-z)"
    fi

    echo $(date "+%a %b %0d %Y %H:%M:%S %Z"): "$line" >> "$logfile"

    # unstash any stashed changes
    if [ $stashed -eq 1 ]
    then
        if git stash pop | grep -iq '^conflict'
        then
            log error - 'unable to restore local changes' 1>&2
            git reset --hard 1> /dev/null
        else
            log debug 'restored' 'local changes'
        fi
    fi

    # rerun when this script was updated
    if [ $before -ne $(stat "$script" -c %Y) ]
    then
        log debug 'rerun' "with args:$opts repair"
        $script$opts repair
        local err=$?
        log debug 'rerun' 'complete'
        exit $err
    fi
}

recent()
{
    # no file, assume not recent
    if [ ! -f "$1" ]
    then
        return 1
    fi

    # valid cooldown arg overrides global setting
    local cooldown=$cooldown
    if [ "$2" -gt 5 ] 2>&-
    then
        local cooldown=$2
    fi

    # seconds between epoch and: now, last commit of file
    local now=$(date +%s)
    local touched=$(git log -n1 --format=%ct "$1")

    # if not commited get last touch
    if [ -z "$touched" ]
    then
        local touched=$(stat -c %Y "$1")
    fi

    # difference more than cooldown means not recent
    if [ $(($now - $touched)) -gt $cooldown ]
    then
        return 1
    fi
}

synched()
{
    # get installed and selected bundles
    local repos=$(ls -1 "$dotfiles/.vim/bundle/" | sort)
    local lines=$(sed -nr "s/^bundle '([^\/]+\/)?([^\/']+)'/\2/pi" "$dotfiles/.vimrc" | sort)

    # do they match?
    diff <(echo "$repos") <(echo "$lines") > /dev/null

    # return answer
    return $?
}

usage()
{
    cat <<- EOF
		Usage: $(basename $script) [-vlevel] [-y] command

		Manages dotfiles and settings from this repo for the current user

		Commands:
		  install - Installs dotfiles for the current user, uses symlinks and github
		  update  - Pulls latest version from github and updates local install
		  remove  - Unlinks dotfiles, but leaves unversioned files
		  clean   - Cleans up unversioned files or directories create by this script

		Options:
		  -c, --cooldown=SECONDS  set cooldown, SECONDS defaults to 32399 (~9 hours)
		                            abort update if within cooldown period
		  -h, --help              show this message
		  -f, --force             force update, same as --cooldown=0
		  -o, --offline           skip any online actions
		  -v, --verbosity=LEVEL   logging level, LEVEL defaults to '7'
		                            flags:
		                              1 error
		                              2 warning
		                              4 notice
		                              8 debug
		  -y, --assume-yes        assume yes to all queries and don't prompt
	EOF
    exit 1
}

vundle()
{
    # build vundle directory
    local vundle="$dotfiles/.vim/bundle/vundle"

    # build readable name
    local vundle_r="$(format "$vundle")"
    local bundle_r="$(format $(dirname "$vundle"))"

    # install when not present
    if [ ! -d $vundle ]
    then
        git clone https://github.com/gmarik/vundle.git $vundle > /dev/null 2>&1
        log notice 'cloned' "$vundle_r"
    else
        log debug 'skipped' "$vundle_r"
    fi

    # when installed and selected bundles don't match, update them
    if ! synched
    then
        vim -u "$dotfiles/.vimrc" -c ':BundleClean!' -c ':BundleInstall' -c ':qa'
        log notice 'updated' "$bundle_r"
    else
        log debug 'skipped' "$bundle_r"
    fi
}

# initialisation logic
##########################################################################

# constants
commands=( clean install remove repair update )
exclude=( . .. .git )

# runtime constants
dotfiles=$(cd "$(dirname $0)" && pwd)
script="$dotfiles/$(basename $0)"
logfile="$dotfiles/manager.log"
excfile="$dotfiles/.git/info/exclude"

# settings
ignore=( "$logfile" "$dotfiles/.vim/bundle" )
dirs=( "$HOME/bin" "$HOME/.cache/swap" "$HOME/.cache/temp" "$HOME/.cache/undo" "$dotfiles/.vim/bundle" )
files=( "$logfile" )

# make sure git doesn't cause us hassle
cd $dotfiles

# default args
interact=1
cooldown=32399
online=1
verbosity=7

# parse args
while getopts c:fhov:y-: OPTION
do
    case $OPTION in
        c)
            cooldown=$OPTARG
            ;;
        f)
            cooldown=0
            ;;
        h)
            usage
            ;;
        o)
            online=0
            ;;
        v)
            verbosity=$OPTARG
            ;;
        y)
            interact=0
            ;;
        -)
            case $OPTARG in
                assume-yes)
                    interact=0
                    ;;
                cooldown=*)
                    cooldown=${OPTARG#*=}
                    ;;
                cooldown)
                    cooldown=${!OPTIND}
                    OPTIND=$(($OPTIND + 1))
                    ;;
                force)
                    cooldown=0
                    ;;
                help)
                    usage
                    ;;
                offline)
                    online=0
                    ;;
                verbosity=*)
                    verbosity=${OPTARG#*=}
                    ;;
                verbosity)
                    verbosity=${!OPTIND}
                    OPTIND=$(($OPTIND + 1))
                    ;;
            esac
            ;;
    esac
    opts="$opts -$OPTION$OPTARG"
done
shift $((OPTIND - 1))

# parse command
for command in "${commands[@]}" null
do
    if [ "$command" = "$1" ]
    then
        break
    fi
done

# help if command missing
if [ "$command" = 'null' ]
then
    usage
fi

# check verbosity is valid
if ! [ "$verbosity" -ge 0 -a "$verbosity" -lt 16 ] 2>&-
then
    verbosity=7
    log warning - 'verbosity must be an integer in range 0-15, defaulting to 7' 1>&2
fi

# check cooldown is valid
if ! [ "$cooldown" -ge 0 ] 2>&-
then
    cooldown=32399
    log warning - 'cooldown must be a positive integer, defaulting to 9 hours' 1>&2
fi

# execution logic
##########################################################################

# prevent unintentional reinstalls
if [ "$command" = 'install' -a -f "$logfile" ]
then
    log warning - 'already installed, try update'
    exit 1
fi

# check that script should be running
if [ "$command" = 'update' -a $cooldown -gt 0 ] && recent "$logfile"
then
    plural=s
    if [ $cooldown -eq 1 ]
    then
        plural=
    fi
    log warning - "updated less than $cooldown second$plural ago" 1>&2
    exit 1
fi

# fold update path into install
if [ "$command" = 'update' ]
then
    command=install
fi

if [ "$command" = 'install' -a $online -eq 1 ]
then
    pull
fi

# fold repair path into install
if [ "$command" = 'repair' ]
then
    command=install
fi

if [ "$command" = 'install' -a ! -d $dotfiles/.vim ]
then
    mkdir $dotfiles/.vim
fi

if [ "$command" != 'clean' ]
then
    for file in $dotfiles/.*
    do
        link "$file" "$HOME"
    done
    
    # enable zsh support
    if [ "$command" = 'remove' ] || which zsh > /dev/null
    then
        link "$dotfiles/.profile" "$HOME/.zprofile"
    fi
fi

if [ "$command" = 'install' -a $online -eq 1 ]
then
    vundle
fi

if [ "$command" != 'remove' ]
then
    # process unversioned files
    for file in "${files[@]}"
    do
        extra 'file' "$file"
    done

    # process unversioned directories
    for dir in "${dirs[@]}"
    do
        extra 'dir' "$dir"
    done
fi

if [ "$command" = 'install' ]
then
    # add some unversioned files to local ignore file
    # this is needed because .gitignore is being managed
    for file in "${ignore[@]}" 
    do
        path=${file#$dotfiles/}
        if ! grep -q "$path" "$excfile"
        then
            echo "$path" >> "$excfile"
            log debug 'buried' "$(format "$file")"
        fi
    done
fi
