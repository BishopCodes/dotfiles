return {
  "nvim-lualine/lualine.nvim",
  opts = function(_, opts)
    -- Add Buffer ID to lualine_c section
    table.insert(opts.sections.lualine_c, {
      function()
        return "BufID:" .. vim.api.nvim_get_current_buf()
      end,
      color = { fg = "#ffaa00" },
    })
  end,
}
