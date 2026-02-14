#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$HOME/Code/dotfiles"
LOG_FILE="$HOME/.local/state/dotfiles-sync.log"
STOW="/opt/homebrew/bin/stow"
GIT="/usr/bin/git"

mkdir -p "$(dirname "$LOG_FILE")"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG_FILE"
}

log "Starting dotfiles sync"

cd "$DOTFILES_DIR"

# Bail out if there are local uncommitted changes to avoid conflicts
if ! "$GIT" diff --quiet || ! "$GIT" diff --cached --quiet; then
    log "Skipping: uncommitted local changes detected"
    exit 0
fi

# Fetch and check if there are upstream changes
"$GIT" fetch --quiet origin main
LOCAL=$("$GIT" rev-parse HEAD)
REMOTE=$("$GIT" rev-parse origin/main)

if [[ "$LOCAL" == "$REMOTE" ]]; then
    log "Already up to date"
    exit 0
fi

# Pull latest changes
"$GIT" pull --ff-only --quiet origin main
log "Pulled $(git rev-parse --short HEAD)"

# Re-stow all packages to apply any new symlinks
packages=()
for dir in */; do
    # Skip non-stow directories
    [[ "$dir" == "bin/" ]] && continue
    packages+=("${dir%/}")
done

"$STOW" -t "$HOME" --restow "${packages[@]}"
log "Restowed: ${packages[*]}"

# Restart borders if its config changed
if "$GIT" diff --name-only "$LOCAL" "$REMOTE" | grep -q '^borders/'; then
    if command -v brew &>/dev/null && brew services list | grep -q 'borders.*started'; then
        /opt/homebrew/bin/brew services restart borders
        log "Restarted borders service"
    fi
fi

log "Sync complete"
