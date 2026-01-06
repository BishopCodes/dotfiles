return {
  "mistweaverco/kulala.nvim",
  keys = {
    { "<leader>Rs", desc = "Send request" },
    { "<leader>Ra", desc = "Send all requests" },
    { "<leader>Rb", desc = "Open scratchpad" },
  },
  ft = { "http", "rest" },
  opts = {
    global_keymaps = false,
  },
  config = function(_, opts)
    local kulala = require("kulala")
    kulala.setup(opts)
    local original_get_env = kulala.get_env or function(key)
      return vim.fn.getenv(key)
    end
    kulala.get_env = function(key)
      local env_value = vim.fn.getenv(key)
      if env_value and env_value ~= vim.NIL and env_value ~= "" then
        return env_value
      end
      return original_get_env(key)
    end
  end,
}
