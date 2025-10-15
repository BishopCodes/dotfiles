-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- vim.keymap.set("n", ",q", function()
--   local pattern = _G._rest_nvim.env_pattern
--   local command = string.format("fd -HI '%s'", pattern)
--   local result = io.popen(command):read("*a")
--
--   local env_list = {}
--   for line in result:gmatch("[^\r\n]+") do
--     table.insert(env_list, line)
--   end
--
--   local rest_functions = require("rest-nvim.functions")
--
--   vim.ui.select(env_list, {
--     prompt = "Select env file ",
--     format_item = function(item)
--       return item
--     end,
--   }, function(choice)
--     if choice == nil then
--       return
--     end
--     rest_functions.env("set", choice)
--   end)
-- end, { desc = "[q]uery envs" })

vim.keymap.set(
  "x",
  "<leader>P",
  [["_dP]],
  { desc = "Delete selection and paste before without changing clipboard" }
)

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

-- vim.keymap.set("n", "<leader><leader>", function()
--   vim.cmd("so")
-- end, { desc = "Source file" })

vim.api.nvim_set_keymap("n", "QQ", ":q!<enter>", { noremap = false })

vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

vim.keymap.set(
  "n",
  "<C-u>",
  "<C-u>zz",
  { noremap = true, silent = true, desc = "Scroll window up half a screen and re-center" }
)
vim.keymap.set(
  "n",
  "<C-d>",
  "<C-d>zz",
  { noremap = true, silent = true, desc = "Scroll window down half a screen and re-center" }
)
vim.keymap.set(
  "i",
  "<C-K>",
  "<Esc>:m .-2<CR>==gi",
  { noremap = true, silent = true, desc = "Move lines up" }
)
vim.keymap.set(
  "i",
  "<C-J>",
  "<Esc>:m .+1<CR>==gi",
  { noremap = true, silent = true, desc = "Move lines down" }
)
vim.keymap.set(
  "v",
  "<C-K>",
  ":m '<-2<CR>gv=gv",
  { noremap = true, silent = true, desc = "Move lines up" }
)
vim.keymap.set(
  "v",
  "<C-J>",
  ":m '>+1<CR>gv=gv",
  { noremap = true, silent = true, desc = "Move lines down" }
)
vim.keymap.set(
  "n",
  "<C-K>",
  ":m .-2<CR>==",
  { noremap = true, silent = true, desc = "Move line up" }
)
vim.keymap.set(
  "n",
  "<C-J>",
  ":m .+1<CR>==",
  { noremap = true, silent = true, desc = "Move line down" }
)

vim.keymap.set("n", "<leader>cD", function()
  local diagnostics = vim.lsp.diagnostic.get_line_diagnostics()
  if not diagnostics or vim.tbl_isempty(diagnostics) then
    print("No diagnostics found on the current line")
    return
  end

  local message = diagnostics[1].message
  vim.fn.setreg("+", message)
  print("Copied diagnostic message to clipboard: " .. message)
end, { noremap = true, silent = true, desc = "Copy diagnostic to clipboard" })
vim.keymap.set("n", "gq", "<cmd>lua vim.lsp.buf.format()<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>rn", ":IncRename ", { desc = "Rename" })
vim.keymap.set(
  "n",
  "<leader>Sey",
  ":call feedkeys(':%%s/^\\s*\\([^=]*\\)=\\(.*\\)/  - name: \\1\\r    value: \\2/', 'n')<CR>",
  { desc = "Convert env lines to YAML", noremap = true, silent = false }
)

vim.keymap.set(
  "n",
  "<leader>fo",
  ":!open -R %<CR>",
  { desc = "Open buffer in finder", noremap = true, silent = false }
)

vim.keymap.set("n", "<leader>ch", "<cmd>FmtVerbHint<cr>", { desc = "Go Format Verb Hint" })

local function add_import()
  local word = vim.fn.expand("<cword>")
  vim.api.nvim_feedkeys("ciw" .. word, "n", false)
  vim.schedule(function()
    vim.api.nvim_feedkeys(
      vim.api.nvim_replace_termcodes("<C-x><C-o>", true, false, true),
      "n",
      false
    )
  end)
end

vim.keymap.set("n", "<leader>Ai", add_import, { desc = "Auto import current word" })

local nw = require("neowarrior")

vim.keymap.set("n", "<leader>Tl", function()
  nw.open_left()
end, { desc = "Open nwarrior on the left side" })
vim.keymap.set("n", "<leader>Tc", function()
  nw.open_current()
end, { desc = "Open nwarrior below current buffer" })
vim.keymap.set("n", "<leader>Tb", function()
  nw.open_below()
end, { desc = "Open nwarrior below current buffer" })
vim.keymap.set("n", "<leader>Ta", function()
  nw.open_above()
end, { desc = "Open nwarrior above current buffer" })
vim.keymap.set("n", "<leader>Tr", function()
  nw.open_right()
end, { desc = "Open nwarrior on the right side" })
vim.keymap.set("n", "<leader>Tt", function()
  nw.focus()
end, { desc = "Focus nwarrior" })
