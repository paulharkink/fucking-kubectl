#!/bin/sh
set -eu

repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)
prefix=${PREFIX:-"$HOME/.local"}

mkdir -p "$prefix/bin"

ln -sf "$repo_dir/bin/please" "$prefix/bin/please"
ln -sf "$repo_dir/bin/fucking" "$prefix/bin/fucking"
ln -sf "$repo_dir/bin/fucking-kubectl" "$prefix/bin/fucking-kubectl"

cat <<EOF
Installed fucking-kubectl.

Commands:
  $prefix/bin/please
  $prefix/bin/fucking
  $prefix/bin/fucking-kubectl

To install zsh completions:

  mkdir -p "\$HOME/.zsh/completions"
  "$prefix/bin/fucking-kubectl" completion zsh please > "\$HOME/.zsh/completions/_please"
  "$prefix/bin/fucking-kubectl" completion zsh fucking > "\$HOME/.zsh/completions/_fucking"

Then make sure ~/.zshrc contains:

  fpath=("\$HOME/.zsh/completions" \$fpath)
  autoload -Uz compinit
  compinit

For oh-my-zsh, put the fpath line before:

  source \$ZSH/oh-my-zsh.sh

To install Bash completions with bash-completion:

  mkdir -p "\$HOME/.local/share/bash-completion/completions"
  "$prefix/bin/fucking-kubectl" completion bash > "\$HOME/.local/share/bash-completion/completions/please"
  "$prefix/bin/fucking-kubectl" completion bash > "\$HOME/.local/share/bash-completion/completions/fucking"

Make sure $prefix/bin is on your PATH.
EOF
