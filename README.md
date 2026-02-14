# Dotfiles

Terminal dev environment managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Tools

| Tool | Purpose | Config |
|------|---------|--------|
| [Ghostty](https://ghostty.org/) | Terminal emulator | `ghostty/.config/ghostty/config` |
| [tmux](https://github.com/tmux/tmux) | Terminal multiplexer | `tmux/.config/tmux/tmux.conf` |
| [Neovim](https://neovim.io/) + [LazyVim](https://www.lazyvim.org/) | Editor | `nvim/.config/nvim/` |
| [Yazi](https://yazi-rs.github.io/) | File manager | `yazi/.config/yazi/` |
| [Lazygit](https://github.com/jesseduffield/lazygit) | Git TUI | `lazygit/.config/lazygit/config.yml` |
| [Fish](https://fishshell.com/) | Shell | `fish/.config/fish/config.fish` |
| [Git](https://git-scm.com/) | Version control | `git/.gitconfig`, `git/.config/git/ignore` |
| [k9s](https://k9scli.io/) | Kubernetes TUI | `k9s/.config/k9s/` |
| [gh-dash](https://github.com/dlvhdr/gh-dash) | GitHub dashboard TUI | `gh-dash/.config/gh-dash/config.yml` |
| [Claude Code](https://claude.com/claude-code) | AI coding assistant | `claude/.claude/` |
| [JankyBorders](https://github.com/FelixKratz/JankyBorders) | Focused window border | `borders/.config/borders/bordersrc` |

## Theme

Catppuccin Mocha everywhere: tmux, Neovim, Yazi, Lazygit, k9s.

## Install

### Prerequisites

```fish
brew install neovim tmux yazi lazygit fish k9s stow
gh extension install dlvhdr/gh-dash
brew install --cask ghostty
brew tap FelixKratz/formulae
brew install borders
```

### Clone and stow

```fish
git clone https://github.com/VincentStark/dotfiles ~/Code/dotfiles
cd ~/Code/dotfiles
stow -t ~ fish nvim tmux yazi lazygit ghostty k9s git claude gh-dash borders
```

### Ghostty macOS symlink

Ghostty reads from `~/Library/Application Support/com.mitchellh.ghostty/config`. After stowing, symlink it:

```fish
ln -sf ~/.config/ghostty/config ~/Library/Application\ Support/com.mitchellh.ghostty/config
```

### tmux plugins

```fish
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
# Then in tmux: prefix + I to install plugins
```

### Yazi plugins

```fish
ya pkg add yazi-rs/plugins:git
ya pkg add yazi-rs/plugins:full-border
ya pkg add yazi-rs/plugins:chmod
```

### JankyBorders

Start the service so it auto-launches on login:

```fish
brew services start borders
```

### Neovim

Open `nvim` — Lazy.nvim and Mason will auto-install everything on first launch.

### Auto-sync (launchd)

A launchd agent pulls the latest dotfiles and restows every hour:

```fish
cp ~/Code/dotfiles/launchd/com.dotfiles.sync.plist ~/Library/LaunchAgents/
launchctl bootstrap gui/(id -u) ~/Library/LaunchAgents/com.dotfiles.sync.plist
```

Logs are written to `~/.local/state/dotfiles-sync.log`. The job skips the pull if there are uncommitted local changes.

To check status:

```fish
launchctl print gui/(id -u)/com.dotfiles.sync
```

To unload:

```fish
launchctl bootout gui/(id -u) ~/Library/LaunchAgents/com.dotfiles.sync.plist
```

## Structure

```
dotfiles/
├── fish/.config/fish/           Fish shell config
├── nvim/.config/nvim/           Neovim + LazyVim
├── tmux/.config/tmux/           tmux
├── yazi/.config/yazi/           Yazi file manager
├── lazygit/.config/lazygit/     Lazygit
├── ghostty/.config/ghostty/     Ghostty terminal
├── git/.gitconfig                Git config
│   └── .config/git/ignore        Global gitignore
├── k9s/.config/k9s/             Kubernetes TUI
├── gh-dash/.config/gh-dash/     GitHub dashboard TUI
├── claude/.claude/              Claude Code config & commands
├── borders/.config/borders/     JankyBorders (focused window border)
├── bin/dotfiles-sync.sh         Auto-sync script (used by launchd)
├── launchd/                     launchd plist (not stowed)
├── TOOLS-CHEATSHEET.md          Keybinding reference
└── README.md
```

Each top-level directory is a Stow package. Running `stow <package>` from the repo root creates symlinks in `~/.config/`.
