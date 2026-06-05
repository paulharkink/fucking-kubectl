_fk_pods() {
  kubectl get pods --no-headers -o custom-columns=:metadata.name 2>/dev/null
}

_fk_resource_types() {
  kubectl api-resources --verbs=delete --namespaced=true -o name 2>/dev/null
}

_fk_resource_names() {
  local type="$1"
  [ -n "$type" ] || return 0
  kubectl get "$type" --no-headers -o custom-columns=:metadata.name 2>/dev/null
}

_fucking_completion() {
  local cur subcommand
  COMPREPLY=()

  cur="${COMP_WORDS[COMP_CWORD]}"
  subcommand="${COMP_WORDS[1]}"

  if [ "$COMP_CWORD" -eq 1 ]; then
    COMPREPLY=($(compgen -W "die nope help --help -h" -- "$cur"))
    return 0
  fi

  case "$subcommand" in
    die)
      if [ "$COMP_CWORD" -eq 2 ]; then
        COMPREPLY=($(compgen -W "$(_fk_pods)" -- "$cur"))
      fi
      ;;
    nope)
      if [ "$COMP_CWORD" -eq 2 ]; then
        COMPREPLY=($(compgen -W "$(_fk_resource_types)" -- "$cur"))
      elif [ "$COMP_CWORD" -eq 3 ]; then
        COMPREPLY=($(compgen -W "$(_fk_resource_names "${COMP_WORDS[2]}")" -- "$cur"))
      fi
      ;;
  esac

  return 0
}

complete -F _fucking_completion fucking
