plugin_dir="${0:A:h}"

export PATH="$plugin_dir/bin:$PATH"
fpath=("$plugin_dir/completions" $fpath)
