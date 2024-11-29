-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- pnpm install -g prettier uglify-js
vim.api.nvim_create_user_command("MinifyJS", function()
  vim.cmd("w")
  local filename = vim.fn.expand("%:p")
  local minified_filename = filename:gsub("%.js$", ".min.js")
  vim.cmd("silent !uglifyjs " .. filename .. " -o " .. minified_filename)
  vim.cmd("edit" .. minified_filename)
end, {})
