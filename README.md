# mux

An intuitive tmux session picker. A ~75‑line POSIX shell script wrapping `fzf` — nothing more.

- Pick, create, kill, detach tmux sessions with fuzzy search
- Live preview of each session (what's actually running in it)
- One binary, one file, no runtime, no plugins
- Works on macOS and Linux (bash or zsh)

## Install

```sh
curl -fsSL https://raw.githubusercontent.com/teriodev95/mux/main/install.sh | sh
```

The installer is idempotent and will:

1. Install `tmux` and `fzf` if missing (via `brew`, `apt`, `dnf`, `pacman`, or `apk`)
2. Drop `mux` in `~/.local/bin/mux`
3. Add `~/.local/bin` to your `PATH` if needed
4. Register `bye` and `det` aliases for quick detach

Every change to your rc files is wrapped in `# >>> mux ... <<<` markers, so removal is trivial.

### From a clone

```sh
git clone https://github.com/teriodev95/mux.git
cd mux
./install.sh
```

Then reload your shell: `source ~/.zshrc` or `source ~/.bashrc`.

## Usage

```
mux                pick a session (type to filter, Enter on query = create new)
mux ls             list sessions
mux new [name]     create/attach a session
mux detach         detach current session (aliases: bye, det) — keeps it alive
mux kill           pick sessions to kill (Tab to multi-select)
mux -h | --help    show help
```

### Typical flow

```sh
mux              # opens picker; type "api" + Enter → creates & attaches "api"
# …work…
bye              # detaches; session keeps running in background
mux              # pick it back up later
mux kill         # tidy up when you're done
```

## Requirements

- `tmux` >= 2.1
- `fzf` (any recent version)
- POSIX `sh`

That's it. No Node, Python, Go, Rust, Homebrew tap, or `~/.config/mux/`.

## Deploy to remote servers

A companion `deploy.sh` is included for installing to SSH hosts:

```sh
./deploy.sh myserver1 myserver2
```

It `scp`'s the script plus installer and runs it remotely. Hosts must be reachable via `ssh <host>` (i.e., already configured in `~/.ssh/config`).

## Uninstall

```sh
rm ~/.local/bin/mux
```

Then delete the `# >>> mux ... <<<` blocks from `~/.zshrc` / `~/.bashrc`.

## Design

Two rules:

1. **Do one thing.** `mux` picks/creates/kills tmux sessions. It does not theme, configure, wrap, or replace tmux.
2. **Don't reinvent what exists.** `fzf` does fuzzy selection beautifully; `tmux` has a rich CLI. `mux` is glue.

Less than 100 lines of shell. Read it before running it.

## License

MIT
