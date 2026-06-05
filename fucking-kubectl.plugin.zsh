plugin_dir="${0:A:h}"

export PATH="$plugin_dir/bin:$PATH"
fpath=("$plugin_dir/completions" $fpath)

if (( $+functions[compdef] )); then
  autoload -Uz _please _fucking
  compdef _please please
  compdef _fucking fucking
fi
