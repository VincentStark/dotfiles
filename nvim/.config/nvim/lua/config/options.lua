-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua

local opt = vim.opt

-- Scrolling
opt.scrolloff = 8 -- LazyVim default is 4

-- Indentation (default; per-filetype overrides in autocmds.lua)
opt.tabstop = 4
opt.shiftwidth = 4

-- Line display
opt.wrap = false

-- Files
opt.swapfile = false
opt.backup = false

-- Performance
opt.updatetime = 250
