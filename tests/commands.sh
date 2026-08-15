#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=tests/test-lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/test-lib.sh"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
make_fake_kubectl "$tmpdir"
export PATH="$tmpdir:$PATH"

please="$repo_root/bin/please"
fucking="$repo_root/bin/fucking"

run_cmd() {
  "$@" | strip_ansi
}

run_rejected() {
  local out="$tmpdir/reject.out"
  local err="$tmpdir/reject.err"
  set +e
  "$@" >"$out" 2>"$err"
  local status=$?
  set -e
  printf '%s' "$status"
}

assert_eq "please stop" \
  "kubectl <delete> <pod> <pod-a>" \
  "$(run_cmd "$please" stop pod-a)"

assert_eq "please stop with namespace" \
  "kubectl <-n> <ai> <delete> <pod> <pod-a>" \
  "$(run_cmd "$please" -n ai stop pod-a)"

assert_eq "please nope" \
  "kubectl <delete> <deployment> <api>" \
  "$(run_cmd "$please" nope deployment api)"

assert_eq "please restart" \
  "kubectl <rollout> <restart> <deployment> <api>" \
  "$(run_cmd "$please" restart api)"

assert_eq "please show defaults to tail" \
  $'kubectl <logs> <--tail=200> <pod-a>\nINFO fake log line' \
  "$(run_cmd "$please" show pod-a)"

assert_eq "please show container defaults to tail" \
  $'kubectl <logs> <--tail=200> <pod-a> <-c> <app>\nINFO fake log line' \
  "$(run_cmd "$please" show pod-a app)"

assert_eq "please show all" \
  $'kubectl <logs> <pod-a> <-c> <app>\nINFO fake log line' \
  "$(run_cmd "$please" show pod-a app --all)"

assert_eq "please follow" \
  $'kubectl <logs> <-f> <pod-a> <-c> <app>\nINFO fake log line' \
  "$(run_cmd "$please" follow pod-a app)"

assert_eq "please rejects post-command kubectl flags" \
  "1" \
  "$(run_rejected "$please" show pod-a -n ai)"
assert_contains "please reject explains flag placement" \
  "Put kubectl flags before the command" \
  "$(cat "$tmpdir/reject.err")"

assert_eq "fucking die" \
  "kubectl <delete> <pod> <pod-a> <--grace-period=0> <--force>" \
  "$(run_cmd "$fucking" die pod-a)"

assert_eq "fucking die with namespace" \
  "kubectl <-n> <ai> <delete> <pod> <pod-a> <--grace-period=0> <--force>" \
  "$(run_cmd "$fucking" -n ai die pod-a)"

assert_eq "fucking nope" \
  "kubectl <delete> <jobs.batch> <import-123> <--grace-period=0> <--force>" \
  "$(run_cmd "$fucking" nope jobs.batch import-123)"

assert_eq "fucking rejects post-command kubectl flags" \
  "1" \
  "$(run_rejected "$fucking" die pod-a --context prod)"
assert_contains "fucking reject explains flag placement" \
  "Put kubectl flags before the command" \
  "$(cat "$tmpdir/reject.err")"
