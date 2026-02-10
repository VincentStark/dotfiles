# Terminal Dev Environment Cheat Sheet

## Tool Integration Map

```
Ghostty (Cmd+T/D/etc) → tmux (prefix: Ctrl+B) → { nvim, yazi, lazygit, claude }
```

---

## Ghostty → tmux Passthrough Keys

| Key | Action |
|-----|--------|
| `Cmd+T` | New tmux window |
| `Cmd+D` | Split pane vertical |
| `Cmd+Shift+D` | Split pane horizontal |
| `Cmd+W` | **Disabled** (safety — use `prefix X` to kill pane) |
| `Cmd+Shift+[` / `]` | Previous / next tmux window |
| `Cmd+1-9` | Switch to tmux window 1-9 |
| `Cmd+Alt+Arrow` | Navigate panes (hjkl) |
| `Cmd+Shift+F` | Zoom pane (fullscreen toggle) |
| `Cmd+Shift+T` | Rename tmux window |

## tmux (prefix: `Ctrl+B`)

| Key | Action |
|-----|--------|
| `prefix c` | New window |
| `prefix p` / `n` | Previous / next window |
| `prefix 1-9` | Switch to window |
| `prefix \|` | Split vertical |
| `prefix -` | Split horizontal |
| `prefix h/j/k/l` | Navigate panes |
| `prefix X` | Kill pane (no confirmation) |
| `prefix z` | Zoom/unzoom pane |
| `prefix ,` | Rename window |
| `prefix d` | Detach session |
| `prefix r` | Reload tmux config |

---

## Neovim / LazyVim (leader: `Space`)

### File Navigation

| Key | Action |
|-----|--------|
| `<leader><space>` | Find files (telescope) |
| `<leader>ff` | Find files (alternative) |
| `<leader>/` | Grep across project |
| `<leader>sg` | Grep (alternative) |
| `<leader>,` | Open buffers |
| `<leader>fb` | Open buffers (alternative) |
| `<leader>sb` | Search in current buffer |
| `<leader>e` | Toggle file tree (neo-tree) |
| `<leader>E` | Reveal current file in neo-tree |
| `<leader>fy` | Open yazi (current file) |
| `<leader>fY` | Open yazi (cwd) |

### Git

| Key | Action |
|-----|--------|
| `<leader>gg` | Open lazygit |
| `<leader>gb` | Git blame (gitsigns) |
| `<leader>gd` | Git diff (gitsigns) |

### LSP

| Key | Action |
|-----|--------|
| `gd` | Go to definition |
| `gr` | Find references |
| `K` | Hover docs |
| `<leader>ca` | Code action |
| `<leader>cr` | Rename symbol |
| `<leader>cd` | Line diagnostics |
| `]d` / `[d` | Next / prev diagnostic |

### Buffers & Windows

| Key | Action |
|-----|--------|
| `<S-h>` / `<S-l>` | Previous / next buffer |
| `<leader>bd` | Delete buffer |
| `<leader>w` | Windows menu |
| `<C-h/j/k/l>` | Navigate windows |
| `:w` | Save |
| `<leader>qq` | Quit all |

### Editing

| Key | Action |
|-----|--------|
| `V` then `J`/`K` | Move selected lines down/up |
| `<C-d>` / `<C-u>` | Scroll half-page (centered) |
| `n` / `N` | Next/prev search (centered) |
| `gcc` | Toggle line comment |
| `gc` (visual) | Toggle comment on selection |

### Help

| Key | Action |
|-----|--------|
| `<leader>` (wait) | Which-key help popup |
| `<leader>sk` | Search keymaps |
| `<leader>sh` | Search help tags |

---

## Yazi (file manager)

### Navigation

| Key | Action |
|-----|--------|
| `h` / `l` | Parent / enter directory |
| `j` / `k` | Move down / up |
| `Enter` | Open file in $EDITOR |
| `o` | Open with system default |
| `/` | Search |
| `q` | Quit |

### Bookmarks

| Key | Action |
|-----|--------|
| `gc` | Go to ~/Code |
| `gd` | Go to ~/Downloads |
| `g.` | Go to ~/.config |

### File Operations

| Key | Action |
|-----|--------|
| `Space` | Select file |
| `y` | Yank (copy) |
| `x` | Cut |
| `p` | Paste |
| `d` | Trash |
| `D` | Permanently delete |
| `r` | Rename |
| `a` | Create file |
| `cm` | chmod (plugin) |
| `.` | Toggle hidden files |

---

## Lazygit

### Navigation

| Key | Action |
|-----|--------|
| `1-5` | Switch panels |
| `h` / `l` | Cycle panels |
| `j` / `k` | Move in list |
| `Enter` | View details |
| `?` | Help / keybindings |
| `q` | Quit |

### Common Operations

| Key | Action |
|-----|--------|
| `Space` | Stage / unstage file |
| `a` | Stage all |
| `c` | Commit |
| `Ctrl+P` | Push |
| `P` | Pull (rebase) |
| `n` | New branch |
| `Enter` (on branch) | Checkout branch |

---

## Common Workflows

1. **Open project**: `cd project && nvim .`
2. **Find file**: `<leader><space>` → type filename
3. **Grep project**: `<leader>/` → type search term
4. **Git workflow**: `<leader>gg` → stage, commit, push in lazygit
5. **Browse files**: `<leader>fy` → navigate with yazi
6. **LSP**: `gd` definition → `gr` references → `K` hover → `<leader>ca` action
7. **Multiple projects**: `Cmd+T` for new tmux window per project
8. **Split editing**: `Cmd+D` vertical split, `Cmd+Alt+Arrow` to navigate
