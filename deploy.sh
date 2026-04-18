#!/bin/sh
# deploy.sh — push mux to remote hosts and install it.
# Usage: ./deploy.sh host1 [host2 ...]

set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

[ $# -ge 1 ] || { echo "usage: $0 <host> [host...]" >&2; exit 1; }

for host in "$@"; do
    printf '\n━━━ %s ━━━\n' "$host"
    ssh "$host" 'mkdir -p ~/.mux-install'
    scp -q "$SCRIPT_DIR/mux" "$SCRIPT_DIR/install.sh" "$host:.mux-install/"
    ssh "$host" 'sh ~/.mux-install/install.sh && rm -rf ~/.mux-install'
done
