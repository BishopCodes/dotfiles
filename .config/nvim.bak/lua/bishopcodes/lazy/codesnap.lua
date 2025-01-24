return {
  'mistricky/codesnap.nvim',
  build = 'make',
  version = '^1',
  lazy = true,
  cmd = { 'CodeSnap', 'CodeSnapSave' },
  config = function()
    require('codesnap').setup {
      mac_window_bar = false,
      has_breadcrumbs = true,
      watermark = '',
      bg_color = '#535c68',
    }
  end,
}
