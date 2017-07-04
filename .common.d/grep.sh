export GREP_OPTS='
  -I
  --color=auto
  --exclude-dir=.git
  --exclude-dir=.svn
  --exclude-dir=node_modules
  --exclude-dir=python_modules
'

grep () {
  set -- $(echo $GREP_OPTS | tr -d '\n') "$@"
  /bin/grep "$@"
}
