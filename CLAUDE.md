# Dotfiles — Project Instructions

This repo is managed with [GNU Stow](https://www.gnu.org/software/stow/). Each top-level directory is a Stow package that symlinks into `~/.config/` (or `~`).

## Adding a new tool

When adding config for a new tool:

1. **Create the Stow package**: `<tool>/.config/<tool>/` mirroring the XDG path structure.
2. **Update `README.md`**: Add the tool to the tools table, prerequisites, `stow` command, directory structure, and any setup steps (e.g. `brew services start`).
3. **Stow it**: Run `stow -t ~ <tool>` to activate the symlinks.
4. **Commit and push** the new package and README changes.

## Modifying existing configs

When changing a tool's config (e.g. tuning colors, keybindings):

1. Edit the file under the Stow package directory (e.g. `borders/.config/borders/bordersrc`), **not** the symlinked file in `~/.config/`. They are the same file via symlink, but always reference the repo path.
2. If a service needs restarting after config changes (e.g. `brew services restart borders`), do so.
3. Commit and push.

## Tool-specific notes

### JankyBorders (`borders/`)

- Config: `borders/.config/borders/bordersrc`
- Draws a colored border around the focused window to distinguish it across monitors.
- Runs as a brew service: `brew services start borders` (auto-starts on login).
- After config changes: `brew services restart borders`.
- The `bordersrc` file is a bash script executed by the `borders` binary — use bash syntax, not fish.
