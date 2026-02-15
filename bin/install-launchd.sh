#!/usr/bin/env bash
set -euo pipefail

# Installs the dotfiles-sync launchd agent by expanding $HOME in the
# plist template and bootstrapping the agent into the current user's
# GUI domain.

DOTFILES_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TEMPLATE="$DOTFILES_DIR/launchd/com.dotfiles.sync.plist"
DEST="$HOME/Library/LaunchAgents/com.dotfiles.sync.plist"
LABEL="com.dotfiles.sync"
DOMAIN="gui/$(id -u)"

if [[ ! -f "$TEMPLATE" ]]; then
    echo "Error: template not found at $TEMPLATE" >&2
    exit 1
fi

mkdir -p "$HOME/Library/LaunchAgents"

# Expand $HOME in the template and write to LaunchAgents
sed "s|\$HOME|$HOME|g" "$TEMPLATE" > "$DEST"
echo "Installed plist to $DEST"

# Unload existing agent if loaded (ignore errors if not loaded)
launchctl bootout "$DOMAIN/$LABEL" 2>/dev/null || true

# Load the agent
launchctl bootstrap "$DOMAIN" "$DEST"
echo "Bootstrapped $LABEL into $DOMAIN"
