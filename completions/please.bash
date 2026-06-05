_fk_pods() {
  kubectl get pods --no-headers -o custom-columns=:metadata.name 2>/dev/null
}

_fk_deployments() {
  kubectl get deployments --no-headers -o custom-columns=:metadata.name 2>/dev/null
}

_fk_resource_types() {
  kubectl api-resources --verbs=delete --namespaced=true -o name 2>/dev/null
}

_fk_resource_names() {
  local type="$1"
  [ -n "$type" ] || return 0
  kubectl get "$type" --no-headers -o custom-columns=:metadata.name 2>/dev/null
}

_fk_containers() {
  local pod="$1"
  [ -n "$pod" ] || return 0
  kubectl get pod "$pod" -o 'jsonpath={range .spec.containers[*]}{.name}{"\n"}{end}' 2>/dev/null
}

_please_completion() {
  local cur prev subcommand
  COMPREPLY=()

  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"
  subcommand="${COMP_WORDS[1]}"

  if [ "$COMP_CWORD" -eq 1 ]; then
    COMPREPLY=($(compgen -W "stop nope restart why sherlock invade help --help -h" -- "$cur"))
    return 0
  fi

  case "$subcommand" in
    stop|die|why|sherlock)
      if [ "$COMP_CWORD" -eq 2 ]; then
        COMPREPLY=($(compgen -W "$(_fk_pods)" -- "$cur"))
      fi
      ;;
    restart)
      if [ "$COMP_CWORD" -eq 2 ]; then
        COMPREPLY=($(compgen -W "$(_fk_deployments)" -- "$cur"))
      fi
      ;;
    nope)
      if [ "$COMP_CWORD" -eq 2 ]; then
        COMPREPLY=($(compgen -W "$(_fk_resource_types)" -- "$cur"))
      elif [ "$COMP_CWORD" -eq 3 ]; then
        COMPREPLY=($(compgen -W "$(_fk_resource_names "${COMP_WORDS[2]}")" -- "$cur"))
      fi
      ;;
    invade)
      if [ "$COMP_CWORD" -eq 2 ]; then
        COMPREPLY=($(compgen -W "$(_fk_pods)" -- "$cur"))
      elif [ "$COMP_CWORD" -eq 3 ]; then
        COMPREPLY=($(compgen -W "$(_fk_containers "${COMP_WORDS[2]}")" -- "$cur"))
      fi
      ;;
  esac

  return 0
}

complete -F _please_completion please
