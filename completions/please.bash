_fk_pods() {
  kubectl "$@" get pods --no-headers -o custom-columns=:metadata.name 2>/dev/null
}

_fk_deployments() {
  kubectl "$@" get deployments --no-headers -o custom-columns=:metadata.name 2>/dev/null
}

_fk_resource_types() {
  kubectl "$@" api-resources --verbs=delete --namespaced=true -o name 2>/dev/null
}

_fk_resource_names() {
  local type="$1"
  shift
  [ -n "$type" ] || return 0
  kubectl "$@" get "$type" --no-headers -o custom-columns=:metadata.name 2>/dev/null
}

_fk_containers() {
  local pod="$1"
  shift
  [ -n "$pod" ] || return 0
  kubectl "$@" get pod "$pod" -o 'jsonpath={range .spec.containers[*]}{.name}{"\n"}{end}' 2>/dev/null
}

_fk_namespaces() {
  kubectl "$@" get namespaces --no-headers -o custom-columns=:metadata.name 2>/dev/null
}

_fk_contexts() {
  kubectl config get-contexts -o name 2>/dev/null
}

_please_completion() {
  local cur prev command="" command_index=1 relative i
  local -a kubectl_args positionals

  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"

  i=1
  while [ "$i" -lt "$COMP_CWORD" ]; do
    case "${COMP_WORDS[$i]}" in
      -n|--namespace|--context|--kubeconfig)
        if [ $((i + 1)) -lt "$COMP_CWORD" ]; then
          kubectl_args+=("${COMP_WORDS[$i]}" "${COMP_WORDS[$((i + 1))]}")
          i=$((i + 2))
        else
          break
        fi
        ;;
      --namespace=*|--context=*|--kubeconfig=*)
        kubectl_args+=("${COMP_WORDS[$i]}")
        i=$((i + 1))
        ;;
      --)
        i=$((i + 1))
        break
        ;;
      -*)
        i=$((i + 1))
        ;;
      *)
        command="${COMP_WORDS[$i]}"
        command_index="$i"
        break
        ;;
    esac
  done

  case "$prev" in
    -n|--namespace)
      COMPREPLY=($(compgen -W "$(_fk_namespaces "${kubectl_args[@]}")" -- "$cur"))
      return 0
      ;;
    --context)
      COMPREPLY=($(compgen -W "$(_fk_contexts)" -- "$cur"))
      return 0
      ;;
    --kubeconfig)
      COMPREPLY=($(compgen -f -- "$cur"))
      return 0
      ;;
  esac

  if [ -z "$command" ] || [ "$COMP_CWORD" -eq "$command_index" ]; then
    if [[ "$cur" == -* ]]; then
      COMPREPLY=($(compgen -W "-n --namespace --context --kubeconfig -h --help" -- "$cur"))
    else
      COMPREPLY=($(compgen -W "stop nope restart why sherlock invade help --help -h" -- "$cur"))
    fi
    return 0
  fi

  if [[ "$cur" == -* ]]; then
    COMPREPLY=($(compgen -W "-n --namespace --context --kubeconfig -h --help" -- "$cur"))
    return 0
  fi

  i=$((command_index + 1))
  while [ "$i" -lt "$COMP_CWORD" ]; do
    case "${COMP_WORDS[$i]}" in
      -n|--namespace|--context|--kubeconfig)
        if [ $((i + 1)) -lt "$COMP_CWORD" ]; then
          kubectl_args+=("${COMP_WORDS[$i]}" "${COMP_WORDS[$((i + 1))]}")
          i=$((i + 2))
        else
          break
        fi
        ;;
      --namespace=*|--context=*|--kubeconfig=*)
        kubectl_args+=("${COMP_WORDS[$i]}")
        i=$((i + 1))
        ;;
      --)
        i=$((i + 1))
        ;;
      -*)
        i=$((i + 1))
        ;;
      *)
        positionals+=("${COMP_WORDS[$i]}")
        i=$((i + 1))
        ;;
    esac
  done

  relative=$((${#positionals[@]} + 1))

  case "$command" in
    stop|die|why|sherlock)
      if [ "$relative" -eq 1 ]; then
        COMPREPLY=($(compgen -W "$(_fk_pods "${kubectl_args[@]}")" -- "$cur"))
      fi
      ;;
    restart)
      if [ "$relative" -eq 1 ]; then
        COMPREPLY=($(compgen -W "$(_fk_deployments "${kubectl_args[@]}")" -- "$cur"))
      fi
      ;;
    nope)
      if [ "$relative" -eq 1 ]; then
        COMPREPLY=($(compgen -W "$(_fk_resource_types "${kubectl_args[@]}")" -- "$cur"))
      elif [ "$relative" -eq 2 ]; then
        COMPREPLY=($(compgen -W "$(_fk_resource_names "${positionals[0]}" "${kubectl_args[@]}")" -- "$cur"))
      fi
      ;;
    invade)
      if [ "$relative" -eq 1 ]; then
        COMPREPLY=($(compgen -W "$(_fk_pods "${kubectl_args[@]}")" -- "$cur"))
      elif [ "$relative" -eq 2 ]; then
        COMPREPLY=($(compgen -W "$(_fk_containers "${positionals[0]}" "${kubectl_args[@]}")" -- "$cur"))
      fi
      ;;
  esac

  return 0
}

complete -F _please_completion please
