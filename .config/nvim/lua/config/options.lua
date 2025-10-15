-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
--
vim.opt.spell = true
vim.opt.textwidth = 100
vim.g.snacks_animate = false

vim.g.lazyvim_blink_main = false

-- vim.api.nvim_create_autocmd("ColorScheme", {
--   pattern = "*",
--   callback = function()
--     vim.cmd("hi Normal guibg=NONE ctermbg=NONE")
--     vim.cmd("hi NormalNC guibg=NONE ctermbg=NONE")
--     vim.cmd("hi SignColumn guibg=NONE ctermbg=NONE")
--     vim.cmd("hi EndOfBuffer guibg=NONE ctermbg=NONE")
--   end,
-- })
