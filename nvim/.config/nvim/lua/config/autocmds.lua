-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua

-- 2-space indentation for web/config filetypes
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("two_space_indent", { clear = true }),
  pattern = {
    "javascript",
    "typescript",
    "typescriptreact",
    "javascriptreact",
    "json",
    "yaml",
    "html",
    "css",
    "vue",
    "svelte",
    "dart",
  },
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
  end,
})

-- Markdown: wrap + linebreak + spell
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("markdown_settings", { clear = true }),
  pattern = { "markdown" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.spell = true
  end,
})

-- Git commit: spell + textwidth
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("gitcommit_settings", { clear = true }),
  pattern = { "gitcommit" },
  callback = function()
    vim.opt_local.spell = true
    vim.opt_local.textwidth = 72
  end,
})
