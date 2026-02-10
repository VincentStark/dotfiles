return {
  -- Mason: ensure LSP servers and tools are installed
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "pyright",
        "ruff",
        "rust-analyzer",
        "lua-language-server",
        "typescript-language-server",
        "css-lsp",
        "html-lsp",
        "json-lsp",
        "yaml-language-server",
        "bash-language-server",
        "taplo",
        "shellcheck",
        "shfmt",
        "prettier",
        "stylua",
      },
    },
  },

  -- LSP server configurations
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        pyright = {
          settings = {
            python = {
              analysis = {
                typeCheckingMode = "strict",
              },
            },
          },
        },
        ruff = {},
        rust_analyzer = {
          settings = {
            ["rust-analyzer"] = {
              check = {
                command = "clippy",
              },
              cargo = {
                allFeatures = true,
              },
            },
          },
        },
        sourcekit = {},
        ts_ls = {},
        cssls = {},
        html = {},
        jsonls = {},
        yamlls = {},
        bashls = {},
        taplo = {},
      },
    },
  },

  -- Flutter tools (separate plugin, not Mason)
  {
    "akinsho/flutter-tools.nvim",
    lazy = false,
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
  },
}
