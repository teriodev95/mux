# mux

An intuitive tmux session picker — ~150 lines of POSIX shell wrapping `fzf`.

Pick, create, detach, and kill tmux sessions with fuzzy search and a live preview of what's running in each one.

## Install

```sh
curl -fsSL https://raw.githubusercontent.com/teriodev95/mux/main/install.sh | sh
```

Works on macOS and Linux. The installer drops `mux` into `~/.local/bin`, ensures it's on your `PATH`, and adds a `bye` alias for quick detach. All changes to rc files are wrapped in `# >>> mux ... <<<` markers.

## Usage

```
mux                pick a session (type + Enter on no match = new)
mux a <name>       attach to session (creates if missing)
mux ls             list sessions
mux detach         detach current session (alias: bye) — keeps it alive
mux kill           pick sessions to kill
```

Typical flow:

```sh
mux            # picker; type "api" + Enter → creates & attaches
# …work…
bye            # detaches; session keeps running
mux            # pick it back up later
```

When you detach, mux prints the exact command to resume, Codex-style:

```
↩ detached from "api" · resume with:  mux a api   (or just:  mux)
```

### Detaching from inside apps

`bye` is a shell alias — it won't fire while a full-screen program (Claude, Codex, vim, htop, …) owns your terminal. The installer binds **`F12`** in tmux to detach instantly from anywhere, even inside those apps. Your session keeps running in the background; pick it back up with `mux`.

If `F12` collides with something you use, edit `~/.tmux.conf` — the binding sits in a `# >>> mux tmux binding <<<` block.

## For AI agents

`mux` exposes a small, non-interactive, machine-readable surface so agents (Claude, Codex, scripts, CI) can drive tmux without a TTY or a picker. Sessions act like background processes with persistence, isolation, and the ability for a human to re-attach later.

```sh
mux ls --json                              # inspect state (JSON array)
mux has build && echo "running"            # predicate — exit 0/1, silent
mux run build -- npm run build             # spawn background task (detached)
mux run build --force -- npm run build     # replace an existing session
mux peek build -n 100                      # observe output + 100 lines scrollback
mux a scratch --no-attach                  # ensure session exists, do not attach
```

### What each command does

**`mux ls --json`** — Emits every session as a JSON array. Fields: `name`, `attached` (bool), `windows` (int), `created` (unix timestamp). Plain `mux ls` stays one-name-per-line for humans; the flag opts into structured output.

```json
[{"name":"api","attached":true,"windows":3,"created":1713470400}]
```

**`mux has <name>`** — Silent predicate. Exit 0 if the session exists, exit 1 otherwise. Use in conditionals: `if mux has deploy; then …`. No output, no color, no noise.

**`mux run <name> [--] <cmd…>`** — Creates a detached session running `<cmd…>`. The `--` separator is optional but recommended when the command has flags of its own. Fails with exit 1 if a session with that name already exists (won't clobber your running work).

**`mux run <name> --force [--] <cmd…>`** — Same as above but kills any existing session with that name first. Useful for restarting a stale build without a manual `kill` step.

**`mux peek <name> [-n LINES]`** — Captures the visible pane of a session without attaching. With `-n N`, includes N lines of scrollback history. An agent can poll `mux peek build -n 100` to observe progress without interrupting the work or needing a TTY. Exits 1 if the session doesn't exist.

**`mux a <name> --no-attach`** — Ensures the session exists (creating it detached if missing) but never attaches. Without `--no-attach`, `mux a` calls `tmux attach-session`, which requires a TTY and will hang for an agent. Use this flag to pre-create empty sessions, or combine with `mux run` in setup scripts.

### Typical agent flow

```sh
mux has deploy || mux run deploy -- ./deploy.sh prod   # spawn only if not running
sleep 30
mux peek deploy -n 200                                 # check progress
mux ls --json | jq '.[] | select(.name=="deploy")'     # inspect structured state
```

When you (the human) are ready to inspect live, run `mux a deploy` from your terminal and you land right in the session.

Note: `mux` (picker) and `mux a <name>` (without `--no-attach`) are interactive and require a TTY — agents should use `--no-attach` or `mux run` instead.

## Requirements

`tmux` and `fzf`. The installer gets them via `brew`, `apt`, `dnf`, `pacman`, or `apk`.

## Uninstall

```sh
rm ~/.local/bin/mux
```

Then remove the `# >>> mux ... <<<` blocks from `~/.zshrc` / `~/.bashrc`.

## License

MIT
