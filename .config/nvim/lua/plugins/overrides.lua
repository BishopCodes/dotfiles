return {
  {
    "hrsh7th/nvim-cmp",
    opts = function(_, opts)
      table.insert(opts.sources, {
        per_filetype = {
          codecompanion = { "codecompanion" },
        },
      })
    end,
  },
}
