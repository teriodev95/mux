#!/bin/sh
# install.sh — portable installer for mux.
# Works from a local clone OR piped from curl:
#   curl -fsSL https://raw.githubusercontent.com/teriodev95/mux/main/install.sh | sh

set -eu

REPO_RAW="https://raw.githubusercontent.com/teriodev95/mux/main"
BIN_DIR="$HOME/.local/bin"
DEST="$BIN_DIR/mux"

info() { printf '→ %s\n' "$*"; }
warn() { printf '! %s\n' "$*" >&2; }

locate_source() {
    # When run locally (./install.sh), mux sits next to install.sh.
    if [ -n "${0:-}" ] && [ -f "$(dirname -- "$0")/mux" ]; then
        printf '%s' "$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)/mux"
    else
        printf ''
    fi
}

ensure_pkg() {
    name=$1
    command -v "$name" >/dev/null 2>&1 && { info "$name: already installed"; return; }
    info "$name: installing…"
    if   command -v brew    >/dev/null 2>&1; then brew install "$name"
    elif command -v apt-get >/dev/null 2>&1; then sudo apt-get update -qq && sudo apt-get install -y "$name"
    elif command -v dnf     >/dev/null 2>&1; then sudo dnf install -y "$name"
    elif command -v pacman  >/dev/null 2>&1; then sudo pacman -S --noconfirm "$name"
    elif command -v apk     >/dev/null 2>&1; then sudo apk add --no-cache "$name"
    else warn "no known package manager — install $name manually"; exit 1
    fi
}

install_binary() {
    mkdir -p "$BIN_DIR"
    src=$(locate_source)
    if [ -n "$src" ]; then
        cp "$src" "$DEST"
    else
        info "downloading mux from $REPO_RAW/mux"
        if   command -v curl >/dev/null 2>&1; then curl -fsSL "$REPO_RAW/mux" -o "$DEST"
        elif command -v wget >/dev/null 2>&1; then wget -q "$REPO_RAW/mux" -O "$DEST"
        else warn "need curl or wget"; exit 1
        fi
    fi
    chmod +x "$DEST"
    info "installed: $DEST"
}

ensure_path() {
    case ":$PATH:" in
        *":$BIN_DIR:"*) info "PATH: $BIN_DIR already present"; return ;;
    esac
    for rc in "$HOME/.zshrc" "$HOME/.bashrc" "$HOME/.profile"; do
        [ -f "$rc" ] || continue
        grep -q 'mux PATH' "$rc" && continue
        {
            printf '\n# >>> mux PATH >>>\n'
            printf 'case ":$PATH:" in *":%s:"*) ;; *) export PATH="%s:$PATH";; esac\n' "$BIN_DIR" "$BIN_DIR"
            printf '# <<< mux PATH <<<\n'
        } >> "$rc"
        info "PATH: added to $rc"
    done
}

ensure_aliases() {
    for rc in "$HOME/.zshrc" "$HOME/.bashrc"; do
        [ -f "$rc" ] || continue
        grep -q 'mux shell integration' "$rc" && { info "aliases: already in $rc"; continue; }
        {
            printf '\n# >>> mux shell integration >>>\n'
            printf "alias bye='mux detach'\n"
            printf "alias det='mux detach'\n"
            printf '# <<< mux shell integration <<<\n'
        } >> "$rc"
        info "aliases: added to $rc"
    done
}

ensure_tmux_conf() {
    conf="$HOME/.tmux.conf"
    if [ -f "$conf" ] && grep -q 'mux tmux binding' "$conf"; then
        info "tmux.conf: already configured"
    else
        {
            printf '\n# >>> mux tmux binding >>>\n'
            printf '# Detach from any app (Claude, Codex, vim, ...) with a single key.\n'
            printf 'bind-key -n F12 detach-client\n'
            printf '# <<< mux tmux binding <<<\n'
        } >> "$conf"
        info "tmux.conf: added F12 detach binding to $conf"
    fi
    if command -v tmux >/dev/null 2>&1 && tmux list-sessions >/dev/null 2>&1; then
        tmux source-file "$conf" >/dev/null 2>&1 && info "tmux: reloaded running server"
    fi
}

main() {
    ensure_pkg tmux
    ensure_pkg fzf
    install_binary
    ensure_path
    ensure_aliases
    ensure_tmux_conf
    info "done. open a new shell (or: source your rc) and run:  mux --help"
}

main "$@"
