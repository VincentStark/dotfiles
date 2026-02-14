if status is-interactive
    # Commands to run in interactive sessions can go here
end

# XDG Base Directories
set -gx XDG_CONFIG_HOME $HOME/.config
set -gx XDG_DATA_HOME $HOME/.local/share
set -gx XDG_STATE_HOME $HOME/.local/state
set -gx XDG_CACHE_HOME $HOME/.cache

# Homebrew
set -gx PATH /opt/homebrew/bin /opt/homebrew/sbin $PATH

# Rust/Cargo (via Homebrew rustup)
# Proxy binaries are managed by rustup in homebrew
set -gx RUSTUP_HOME $HOME/.rustup
set -gx CARGO_HOME $HOME/.cargo
# Add the toolchain and cargo bin directories to PATH
set -gx PATH $HOME/.cargo/bin $HOME/.rustup/toolchains/stable-aarch64-apple-darwin/bin $PATH

# Flutter
set -gx PATH $HOME/flutter/bin $PATH

# Local binaries
set -gx PATH $HOME/.local/bin $PATH

# Editor
set -gx EDITOR nvim
set -gx VISUAL nvim

# Google Cloud SDK
set -gx USE_GKE_GCLOUD_AUTH_PLUGIN True

# Aliases
alias vim nvim
alias river 'gcloud auth login && gcloud auth application-default login'
alias claude 'claude --dangerously-skip-permissions --teammate-mode in-process'
alias lg lazygit

# OpenClaw Completion
if test -f "$HOME/.openclaw/completions/openclaw.fish"
    source "$HOME/.openclaw/completions/openclaw.fish"
end
