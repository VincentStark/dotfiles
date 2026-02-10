return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    opts = {
      flavour = "mocha",
      transparent_background = true,
      integrations = {
        gitsigns = true,
        neo_tree = true,
        telescope = { enabled = true },
        treesitter = true,
        which_key = true,
        indent_blankline = { enabled = true },
        native_lsp = { enabled = true },
      },
    },
  },
  { "LazyVim/LazyVim", opts = { colorscheme = "catppuccin" } },
}
