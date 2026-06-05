# fucking-kubectl

Polite and impolite Kubernetes shortcuts for the commands you type when a pod is either asking nicely or absolutely refusing to cooperate.

`please` is the normal path. `fucking` is the escalation path.

```sh
please stop api-7d9f8b6c9d-j2k4m
fucking die api-7d9f8b6c9d-j2k4m
```

Both commands use your active `kubectl` context and namespace. No namespace flags are added for you.

## Commands

### `please`

```sh
please stop POD
```

Delete a pod normally.

```sh
please nope TYPE NAME
```

Delete any namespaced resource normally.

```sh
please restart DEPLOYMENT
```

Run a deployment rollout restart.

```sh
please why POD
please sherlock POD
```

Show a focused pod diagnosis:

```sh
kubectl get pod POD -o wide
kubectl get events --field-selector involvedObject.name=POD --sort-by=.lastTimestamp
kubectl logs POD --previous --tail=200
```

```sh
please invade POD [CONTAINER]
```

Open an interactive shell in a pod. It tries `zsh`, then `bash`, then `sh`.

### `fucking`

```sh
fucking die POD
```

Force-delete a pod immediately.

```sh
fucking nope TYPE NAME
```

Force-delete any namespaced resource immediately.

## Completion

Zsh completions are included for both commands.

They complete:

- command names
- pods in the current namespace
- dynamic deletable resource types from `kubectl api-resources --verbs=delete --namespaced=true -o name`
- resource names for `please nope` and `fucking nope`
- container names for `please invade POD CONTAINER`

Completion does not require oh-my-zsh. It only needs zsh completion via `compinit`.

## Install

Clone the repo:

```sh
git clone https://github.com/paulharkink/fucking-kubectl.git
cd fucking-kubectl
./install.sh
```

The installer symlinks:

```text
~/.local/bin/please
~/.local/bin/fucking
~/.zsh/completions/_please
~/.zsh/completions/_fucking
```

Add this to `~/.zshrc` if you do not already have a zsh completion setup:

```sh
export PATH="$HOME/.local/bin:$PATH"
fpath=("$HOME/.zsh/completions" $fpath)
autoload -Uz compinit
compinit
```

For oh-my-zsh users, put the `fpath` line before:

```sh
source $ZSH/oh-my-zsh.sh
```

## oh-my-zsh plugin style

You can also install it as a custom oh-my-zsh plugin:

```sh
git clone https://github.com/paulharkink/fucking-kubectl.git \
  ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fucking-kubectl
```

Then add it to `~/.zshrc`:

```sh
plugins=(... fucking-kubectl)
```

The plugin file adds `bin/` to `PATH` and `completions/` to `fpath`.

## Examples

```sh
please restart api
please why api-7d9f8b6c9d-j2k4m
please invade api-7d9f8b6c9d-j2k4m app
please nope deployments.apps api
fucking nope jobs.batch import-123
```

## Requirements

- `kubectl`
- `zsh` for completions
- enough Kubernetes permissions for whatever you ask the commands to do

The commands themselves are small Bash scripts.
