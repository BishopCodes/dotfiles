vim.keymap.set('n', '<leader>pv', vim.cmd.Ex, { desc = 'File tree' })

-- greatest remap ever
vim.keymap.set('x', '<leader>P', [["_dP]], { desc = 'Delete selection and paste before without changing clipboard' })

-- next greatest remap ever : asbjornHaland
vim.keymap.set({ 'n', 'v' }, '<leader>y', [["+y]], { desc = 'Yank text to buffer' })
vim.keymap.set('n', '<leader>Y', [["+yy]], { desc = 'Yank text to system clipboard' })

vim.keymap.set({ 'n', 'v' }, '<leader>D', [["_d]], { desc = 'Delete without changing clipboard' })

vim.keymap.set('i', '<C-c>', '<Esc>')
vim.keymap.set('n', '<leader>fr', [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = 'Interactive search and replace for word under cursor' })

vim.keymap.set('n', '<leader><leader>', function()
  vim.cmd 'so'
end, { desc = 'Source file' })

vim.api.nvim_set_keymap('n', 'QQ', ':q!<enter>', { noremap = false })

vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

vim.keymap.set('n', '<C-u>', '<C-u>zz', { desc = 'Scroll window up half a screen and re-center' })
vim.keymap.set('n', '<C-d>', '<C-d>zz', { desc = 'Scroll window down half a screen and re-center' })
vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv", { desc = 'Move lines down' })
vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv", { desc = 'Move lines up' })

vim.keymap.set('n', '<leader>gf', vim.lsp.buf.format, { desc = 'Format file' })

vim.keymap.set('n', '<leader>u', vim.cmd.UndotreeToggle, { desc = 'Toggle undo tree' })

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous [D]iagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next [D]iagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror messages' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- TIP: Disable arrow keys in normal mode
-- vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
-- vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
-- vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
-- vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

vim.keymap.set('n', '<leader>tt', '<cmd>TroubleToggle<cr>', { silent = true, noremap = true, desc = ' [T]rouble [T]oggle' })
vim.keymap.set(
  'n',
  '<leader>twd',
  '<cmd>TroubleToggle workspace_diagnostics<cr>',
  { silent = true, noremap = true, desc = '[T]oggle [W]orkspace [D]iagnostics' }
)
vim.keymap.set('n', '<leader>tdd', '<cmd>TroubleToggle document_diagnostics<cr>', { silent = true, noremap = true, desc = '[T]oggle [D]ocument [D]iagnostics' })
vim.keymap.set('n', '<leader>tll', '<cmd>TroubleToggle loclist<cr>', { silent = true, noremap = true, desc = '[T]oggle [L]ocal [L]ist' })
vim.keymap.set('n', '<leader>tdq', '<cmd>TroubleToggle quickfix<cr>', { silent = true, noremap = true, desc = '[T]oggle [Q]uickfix' })
vim.keymap.set('n', '<leader>tR', '<cmd>TroubleToggle lsp_references<cr>', { silent = true, noremap = true, desc = '[T]oggle [R]eferences' })
