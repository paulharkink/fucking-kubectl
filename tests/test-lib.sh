#!/usr/bin/env bash
set -euo pipefail

# shellcheck disable=SC2034
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

strip_ansi() {
  sed -E $'s/\x1b\\[[0-9;]*m//g'
}

pass() {
  printf 'ok - %s\n' "$1"
}

fail() {
  printf 'not ok - %s\n' "$1" >&2
  shift || true
  if [ "$#" -gt 0 ]; then
    printf '%s\n' "$@" >&2
  fi
  exit 1
}

assert_eq() {
  local name="$1"
  local expected="$2"
  local actual="$3"

  if [ "$actual" != "$expected" ]; then
    fail "$name" "expected:" "$expected" "actual:" "$actual"
  fi

  pass "$name"
}

assert_contains() {
  local name="$1"
  local needle="$2"
  local haystack="$3"

  if [[ "$haystack" != *"$needle"* ]]; then
    fail "$name" "missing: $needle" "actual:" "$haystack"
  fi

  pass "$name"
}

make_fake_kubectl() {
  local dir="$1"
  mkdir -p "$dir"
  cat >"$dir/kubectl" <<'SCRIPT'
#!/usr/bin/env bash
set -euo pipefail

if [ "${FK_FAKE_KUBECTL_TRACE:-1}" != "0" ]; then
  printf 'kubectl'
  for arg in "$@"; do
    printf ' <%s>' "$arg"
  done
  printf '\n'
fi

args=("$@")
i=0
while [ "$i" -lt "${#args[@]}" ]; do
  case "${args[$i]}" in
    -n|--namespace|--context|--kubeconfig)
      i=$((i + 2))
      ;;
    --namespace=*|--context=*|--kubeconfig=*)
      i=$((i + 1))
      ;;
    *)
      break
      ;;
  esac
done

cmd="${args[$i]:-}"
next="${args[$((i + 1))]:-}"

if [ "$cmd" = "logs" ]; then
  printf 'INFO fake log line\n'
fi

if [ "$cmd" = "get" ]; then
  case "$next" in
    pods)
      printf 'pod-a\npod-b\n'
      ;;
    deployments)
      printf 'api\nworker\n'
      ;;
    namespaces)
      printf 'default\nai\nhermes\n'
      ;;
    pod)
      printf 'app sidecar\n'
      ;;
    *)
      printf 'resource-a\nresource-b\n'
      ;;
  esac
fi

if [ "$cmd" = "api-resources" ]; then
  printf 'pods\ndeployments.apps\njobs.batch\n'
fi
SCRIPT
  chmod +x "$dir/kubectl"
}
