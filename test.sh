#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$repo_root"

tests/pretty-logs.sh
tests/commands.sh
tests/install.sh
tests/completions.sh

bash -n bin/please bin/fucking bin/fucking-kubectl install.sh tests/*.sh completions/please.bash completions/fucking.bash
zsh -n completions/_please completions/_fucking

if command -v shellcheck >/dev/null 2>&1; then
  shellcheck -x bin/please bin/fucking bin/fucking-kubectl install.sh test.sh tests/*.sh completions/please.bash completions/fucking.bash
else
  printf 'skip - shellcheck not installed\n'
fi

if command -v shfmt >/dev/null 2>&1; then
  shfmt -d -i 2 -ci -bn bin install.sh test.sh tests completions/*.bash
else
  printf 'skip - shfmt not installed\n'
fi
