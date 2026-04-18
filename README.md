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
mux ls             list sessions
mux new <name>     create/attach a session
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

## Requirements

`tmux` and `fzf`. The installer gets them via `brew`, `apt`, `dnf`, `pacman`, or `apk`.

## Uninstall

```sh
rm ~/.local/bin/mux
```

Then remove the `# >>> mux ... <<<` blocks from `~/.zshrc` / `~/.bashrc`.

## License

MIT
