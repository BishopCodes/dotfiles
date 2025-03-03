return {
  "folke/snacks.nvim",
  ---@type snacks.Config
  opts = {
    explorer = {
      replace_netrw = true,
    },
    picker = {
      sources = {
        explorer = {
          hidden = true,
        },
      },
    },
  },
}
