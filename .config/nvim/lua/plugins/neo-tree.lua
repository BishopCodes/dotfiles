return {
  "neo-tree.nvim",
  opts = function(_, opts)
    opts.filesystem.filtered_items = {}
    opts.filesystem.filtered_items.hide_gitignored = true
    opts.filesystem.filtered_items.hide_dotfiles = false
    opts.filesystem.filtered_items.visible = true
  end,
}
