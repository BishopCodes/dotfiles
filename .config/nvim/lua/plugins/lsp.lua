return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      rust_analyzer = {
        enabled = false,
        procMacro = {
          enable = true,
        },
        cargo = {
          allFeatures = true,
        },
      },
      pyright = {
        settings = {
          python = {
            pythonPath = ".venv/bin/python",
            venvPath = ".",
          },
        },
      },
    },
  },
}
