return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      rust_analyzer = {
        enabled = false,
      },
      pyright = {
        settings = {
          python = {
            pythonPath = ".venv/bin/python",
            venvPath = ".",
          },
        },
      },
      eslint = {
        settings = {
          format = false,
          workingDirectory = { mode = "auto" },
        },
        root_dir = function(fname)
          local util = require("lspconfig.util")
          return util.root_pattern(
            ".eslintrc",
            ".eslintrc.js",
            ".eslintrc.json",
            "eslint.config.js",
            "package.json"
          )(fname) or vim.fs.dirname(vim.fs.find(fname, { path = ".", upward = true })[1])
        end,
      },
    },
  },
}
