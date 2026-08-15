#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=tests/test-lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/test-lib.sh"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

make_fake_kubectl "$tmpdir"
export PATH="$tmpdir:$PATH"
export FK_FAKE_KUBECTL_TRACE=0

bash -n "$repo_root/completions/please.bash" "$repo_root/completions/fucking.bash"
zsh -n "$repo_root/completions/_please" "$repo_root/completions/_fucking"
pass "completion scripts parse"

bash_complete() {
  local script="$1"
  local fn="$2"
  shift 2
  bash -c '
    source "$1"
    shift
    fn="$1"
    shift
    COMP_WORDS=("$@")
    COMP_CWORD=$((${#COMP_WORDS[@]} - 1))
    "$fn"
    printf "%s\n" "${COMPREPLY[@]}"
  ' bash "$script" "$fn" "$@"
}

assert_contains "please bash completes command names" \
  "show" \
  "$(bash_complete "$repo_root/completions/please.bash" _please_completion please sh)"

assert_contains "please bash completes pods after namespace flag" \
  "pod-a" \
  "$(bash_complete "$repo_root/completions/please.bash" _please_completion please -n ai invade p)"

assert_contains "please bash completes containers after pod" \
  "sidecar" \
  "$(bash_complete "$repo_root/completions/please.bash" _please_completion please invade pod-a s)"

assert_contains "please bash completes --all after show pod" \
  "--all" \
  "$(bash_complete "$repo_root/completions/please.bash" _please_completion please show pod-a -)"

assert_contains "fucking bash completion installs" \
  "_fucking_completion" \
  "$(bash -c "source '$repo_root/completions/fucking.bash'; complete -p fucking")"

assert_contains "fucking bash completes resource types" \
  "jobs.batch" \
  "$(bash_complete "$repo_root/completions/fucking.bash" _fucking_completion fucking nope j)"

assert_contains "zsh please completion completes --all" \
  "compadd -- --all" \
  "$(cat "$repo_root/completions/_please")"

assert_contains "zsh fucking completion uses dynamic resource types" \
  "api-resources --verbs=delete --namespaced=true" \
  "$(cat "$repo_root/completions/_fucking")"
