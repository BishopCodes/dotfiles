-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("n", ",q", function()
  local pattern = _G._rest_nvim.env_pattern
  local command = string.format("fd -HI '%s'", pattern)
  local result = io.popen(command):read("*a")

  local env_list = {}
  for line in result:gmatch("[^\r\n]+") do
    table.insert(env_list, line)
  end

  local rest_functions = require("rest-nvim.functions")

  vim.ui.select(env_list, {
    prompt = "Select env file ",
    format_item = function(item)
      return item
    end,
  }, function(choice)
    if choice == nil then
      return
    end
    rest_functions.env("set", choice)
  end)
end, { desc = "[q]uery envs" })

vim.keymap.set("x", "<leader>P", [["_dP]], { desc = "Delete selection and paste before without changing clipboard" })

vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]], { desc = "Yank text to buffer" })
vim.keymap.set("n", "<leader>Y", [["+yy]], { desc = "Yank text to system clipboard" })

vim.keymap.set({ "n", "v" }, "<leader>D", [["_d]], { desc = "Delete without changing clipboard" })

vim.keymap.set("i", "<C-c>", "<Esc>")
vim.keymap.set(
  "n",
  "<leader>Fr",
  [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
  { desc = "Interactive search and replace for word under cursor" }
)

vim.keymap.set("n", "<leader><leader>", function()
  vim.cmd("so")
end, { desc = "Source file" })

vim.api.nvim_set_keymap("n", "QQ", ":q!<enter>", { noremap = false })

vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll window up half a screen and re-center" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll window down half a screen and re-center" })
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move lines down" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move lines up" })

vim.keymap.set("n", "<leader>U", vim.cmd.UndotreeToggle, { desc = "Toggle undo tree" })
