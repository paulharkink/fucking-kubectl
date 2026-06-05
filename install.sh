#!/bin/sh
set -eu

repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)
prefix=${PREFIX:-"$HOME/.local"}
zsh_completion_dir=${ZSH_COMPLETION_DIR:-"$HOME/.zsh/completions"}

mkdir -p "$prefix/bin" "$zsh_completion_dir"

ln -sf "$repo_dir/bin/please" "$prefix/bin/please"
ln -sf "$repo_dir/bin/fucking" "$prefix/bin/fucking"
ln -sf "$repo_dir/completions/_please" "$zsh_completion_dir/_please"
ln -sf "$repo_dir/completions/_fucking" "$zsh_completion_dir/_fucking"

cat <<EOF
Installed fucking-kubectl.

Commands:
  $prefix/bin/please
  $prefix/bin/fucking

Zsh completions:
  $zsh_completion_dir/_please
  $zsh_completion_dir/_fucking

Add this to ~/.zshrc if needed:

  export PATH="$prefix/bin:\$PATH"
  fpath=("$zsh_completion_dir" \$fpath)
  autoload -Uz compinit
  compinit

For oh-my-zsh, put the fpath line before:

  source \$ZSH/oh-my-zsh.sh
EOF
