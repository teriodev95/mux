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

`mux` exposes a small, non-interactive, machine-readable surface so agents can drive tmux without a TTY or a picker.

```sh
mux ls --json                              # inspect state (JSON array)
mux has build && echo "running"            # predicate — exit 0/1, silent
mux run build -- npm run build             # spawn background task (detached)
mux run build --force -- npm run build     # replace an existing session
mux peek build -n 100                      # observe output + 100 lines scrollback
mux a scratch --no-attach                  # ensure session exists, do not attach
```

Note: `mux` and `mux a <name>` (without `--no-attach`) attach interactively — agents without a TTY should use `--no-attach` or `mux run` instead.

## Requirements

`tmux` and `fzf`. The installer gets them via `brew`, `apt`, `dnf`, `pacman`, or `apk`.

## Uninstall

```sh
rm ~/.local/bin/mux
```

Then remove the `# >>> mux ... <<<` blocks from `~/.zshrc` / `~/.bashrc`.

## License

MIT
