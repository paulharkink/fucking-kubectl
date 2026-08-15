#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=tests/test-lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/test-lib.sh"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

install_out="$tmpdir/install.out"
PREFIX="$tmpdir/prefix" "$repo_root/install.sh" >"$install_out"

for command in please fucking fucking-kubectl; do
  target="$tmpdir/prefix/bin/$command"
  if [ ! -L "$target" ]; then
    fail "install creates $command symlink" "$target is not a symlink"
  fi
  pass "install creates $command symlink"
done

assert_eq "installed helper prints zsh please completion" \
  "$(cat "$repo_root/completions/_please")" \
  "$("$tmpdir/prefix/bin/fucking-kubectl" completion zsh please)"

assert_eq "installed helper prints zsh fucking completion" \
  "$(cat "$repo_root/completions/_fucking")" \
  "$("$tmpdir/prefix/bin/fucking-kubectl" completion zsh fucking)"

assert_eq "installed helper prints bash completions" \
  "$(cat "$repo_root/completions/please.bash" "$repo_root/completions/fucking.bash")" \
  "$("$tmpdir/prefix/bin/fucking-kubectl" completion bash)"

assert_contains "installer explains manual completion setup" \
  "It does not install shell completions automatically." \
  "$(cat "$install_out")"
