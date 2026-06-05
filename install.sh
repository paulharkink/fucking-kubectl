#!/bin/sh
set -eu

repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)
prefix=${PREFIX:-"$HOME/.local"}
zsh_completion_dir=${ZSH_COMPLETION_DIR:-"$HOME/.zsh/completions"}
bash_completion_dir=${BASH_COMPLETION_DIR:-"$HOME/.local/share/bash-completion/completions"}

mkdir -p "$prefix/bin" "$zsh_completion_dir" "$bash_completion_dir"

ln -sf "$repo_dir/bin/please" "$prefix/bin/please"
ln -sf "$repo_dir/bin/fucking" "$prefix/bin/fucking"
ln -sf "$repo_dir/completions/_please" "$zsh_completion_dir/_please"
ln -sf "$repo_dir/completions/_fucking" "$zsh_completion_dir/_fucking"
ln -sf "$repo_dir/completions/please.bash" "$bash_completion_dir/please"
ln -sf "$repo_dir/completions/fucking.bash" "$bash_completion_dir/fucking"

cat <<EOF
Installed fucking-kubectl.

Commands:
  $prefix/bin/please
  $prefix/bin/fucking

Zsh completions:
  $zsh_completion_dir/_please
  $zsh_completion_dir/_fucking

Bash completions:
  $bash_completion_dir/please
  $bash_completion_dir/fucking

Add this to ~/.zshrc if needed:

  export PATH="$prefix/bin:\$PATH"
  fpath=("$zsh_completion_dir" \$fpath)
  autoload -Uz compinit
  compinit

For oh-my-zsh, put the fpath line before:

  source \$ZSH/oh-my-zsh.sh

For Bash, install bash-completion and source it from ~/.bashrc if your distro
does not already do so.
EOF
