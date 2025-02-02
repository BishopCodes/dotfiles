return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    "jellydn/spinner.nvim",
  },
  keys = { { "<leader>A", group = "AI Code Companion", mode = { "n", "v" } } },
  config = function(_, options)
    require("codecompanion").setup(vim.tbl_deep_extend("force", {
      adapters = {
        deepseek = require("codecompanion.adapters").extend("ollama", {
          schema = {
            model = {
              default = "deepseek-r1:14b",
            },
            num_ctx = {
              default = 16384,
            },
            num_predict = {
              default = -1,
            },
          },
        }),
      },
      strategies = {
        chat = {
          adapter = "deepseek",
          keymaps = {
            send = {
              modes = { n = "<C-s>", i = "<C-s>" },
            },
            close = {
              modes = { n = "<C-c>", i = "<C-c>" },
            },
          },
          slash_commands = {
            ["file"] = {
              callback = "strategies.chat.slash_commands.file",
              description = "Select a file using Telescope",
              opts = {
                provider = "telescope", -- Other options include 'default', 'mini_pick', 'fzf_lua', snacks
                contains_code = true,
              },
            },
          },
        },
        inline = {
          adapter = "deepseek",
          keymaps = {
            accept_change = {
              modes = { n = "<leader>a" },
              description = "Accept the suggested change",
            },
            reject_change = {
              modes = { n = "<leader>r" },
              description = "Reject the suggested change",
            },
          },
        },
      },
      opts = {
        log_level = "DEBUG",
      },
    }, options))

    local spinner = require("spinner")
    local group = vim.api.nvim_create_augroup("CodeCompanionHooks", {})
    vim.api.nvim_create_autocmd({ "User" }, {
      pattern = "CodeCompanionRequest*",
      group = group,
      callback = function(request)
        if request.match == "CodeCompanionRequestStarted" then
          spinner.show()
        end
        if request.match == "CodeCompanionRequestFinished" then
          spinner.hide()
        end
      end,
    })
  end,
}
