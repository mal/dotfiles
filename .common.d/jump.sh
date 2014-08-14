export JMP_LIST=""
export JMP_OPTS=""
export JMP_PATH=$HOME/code

jmp() {
    local dir="$(_jmp_list path $1)"

    if [ -n "$dir" ]
        then cd "$dir"; return
    fi

    local dir="$(_jmp_search -name .git -path "*/$1/.git" -type d | head -n1)"

    if [ -n "$dir" ]
        then cd "$(dirname "$dir")"
        else echo "err: unknown jump" >&2; return 1
    fi
}

_jmp_completion() {
    reply=( \
        $(_jmp_list names) \
        $(_jmp_search -name .git -type d | xargs -n1 dirname | xargs -n1 basename) \
    )
}

_jmp_list() {
    case "$1" in
        names)
            echo "$JMP_LIST" | tr ':' '\n' | cut -d\| -f1
            ;;
        path)
            echo "$JMP_LIST" | tr ':' '\n' | grep "^$2|" | cut -d\| -f2
            ;;
    esac
}

_jmp_search() {
    local IFS="$(echo \'\\n\')"
    set -- $(echo $JMP_PATH | tr ':' '\n') $(echo $JMP_OPTS | tr ' ' '\n') "$@"
    unset IFS

    find "$@"
}

if type compctl &> /dev/null
  then compctl -x 'p[1]' -K _jmp_completion -- jmp
fi
