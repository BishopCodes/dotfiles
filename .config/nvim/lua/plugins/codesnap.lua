return {
  "mistricky/codesnap.nvim",
  build = "make",
  version = "^1",
  lazy = true,
  -- cmd = { "CodeSnap", "CodeSnapSave", "CodeSnapHighlight", "CodeSnapASCII" },
  cmd = { "CodeSnap", "CodeSnapSave" },
  config = function()
    require("codesnap").setup({
      mac_window_bar = false,
      has_breadcrumbs = true,
      has_line_number = true,
      watermark = "",
      bg_color = "#535c68",
      bg_padding = 0,
    })
  end,
}
