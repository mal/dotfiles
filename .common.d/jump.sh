export JMP_LIST=""
export JMP_OPTS=""
export JMP_PATH=$HOME/code

jmp()
{
  local dir="$(_jmp_list path $1)"

  if [ -n "$dir" ]
    then cd "$dir"; return
  fi

  local dir="$(_jmp_search -path "*/$1/.git" | head -n1)"

  if [ -n "$dir" ]
    then cd "$(dirname "$dir")"
    else echo "err: unknown jump" >&2; return 1
  fi
}

_jmp_list()
{
  echo "$JMP_LIST" | tr ':' '\n' | case "$1" in
    names) cut -d\| -f1 ;;
    path) grep "^$2|" | cut -d\| -f2 ;;
  esac
}

_jmp_search()
{
  local IFS="$(printf '\nn')"; IFS="${IFS%n}"
  set -- $(echo $JMP_PATH | tr ':' '\n') $(echo $JMP_OPTS | tr ' ' '\n') \
    -name .git -type d "$@"
  unset IFS

  find "$@"
}

if type compctl > /dev/null 2>&1; then
  _jmp_comp()
  {
    reply=($(_jmp_list names) $(_jmp_search | rev | cut -d/ -f2 | rev))
  }
  compctl -x 'p[1]' -K _jmp_comp -- jmp
fi
