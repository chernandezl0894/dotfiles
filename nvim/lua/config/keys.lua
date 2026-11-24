vim.g.mapleader = " "
vim.g.maplocalleader = " "

local map = function(mode, shortcut, cmd, options)
  vim.keymap.set(mode, shortcut, cmd, options or {})
end

map("t", "<esc>", "<C-\\><C-n>", { desc = "Leave Terminal mode (if in terminal)" })
map('n', '<leader>pv', vim.cmd.Ex, { desc = 'Open Explorer File Tree' })
map("n", "<leader>k", ":nohlsearch<CR>", { desc = "[C]lear search [H]ighight" }) -- clear search highlight
map("n", "<leader>bx", ":bw<CR>", { desc = "[B]uffer [X]close (wipeout)" })      -- completely deletes current buffer (buffer wipeout)
map('n', '<leader>bd', '<CMD>bufdo bdelete<CR>', { desc = 'Delete Current Buffer' })
map('n', '<C-d>', '<C-d>zz')
map('n', '<C-u>', '<C-u>zz')
map('n', 'n', 'nzzzv', { desc = 'Keep Centered Layout on Search Traveling and Open Folder' })
map('n', 'N', 'Nzzzv', { desc = 'Keep Centered Layout on Search Traveling and Open Folder' })
map('x', '<leader>p', [["_dP]], { desc = 'Better Way to Paster' })
map('v', 'p', '"_dP', { desc = 'Paste replace visual selection without copying it' })
map('v', '<', '<gv', { desc = 'Keep Selection On Regrouping Tab' })
map('v', '>', '>gv', { desc = 'Keep Selection On Regrouping Tab' })
map('v', 'y', 'myy`y', { desc = 'Maintain the cursor position when yangin a visual selection' })
map('v', 'Y', 'myY`y', { desc = 'Maintain the cursor position when yangin a visual selection' })
map('n', '<leader>.', function()
  local os_name = jit.os

  if os_name == "Windows" then
    vim.cmd("!explorer.exe .")
  elseif os_name == "Linux" then
    vim.cmd("!xdg-open .")
  else
    print("Unsuported operaty system.")
  end
end, { desc = 'Open the current folder' })
map('n', '<C-Up>', '<CMD>resize +2<CR>', { desc = 'Resize With Arrows' })
map('n', '<C-Down>', '<CMD>resize -2<CR>', { desc = 'Resize With Arrows' })
map('n', '<C-Left>', '<CMD>vertical resize -2<CR>', { desc = 'Resize With Arrows' })
map('n', '<C-Right>', '<CMD>vertical resize +2<CR>', { desc = 'Resize With Arrows' })
map("n", "<leader>sv", "<C-w>v", { desc = "[S]plit [V]ertically" })              -- split vertically
map("n", "<leader>sh", "<C-w>s", { desc = "[S]plit [H]orizontally" })            -- split horizontally
map("n", "<leader>se", "<C-w>=", { desc = "Make Split Windows [=]equal width" }) -- make split windows equal width.
map("n", "<leader>sx", ":close<CR>", { desc = "Current [S]plit [X]Close" })      -- close current split window.
map("n", "<leader>z", ":set wrap!<CR>", { desc = "Toggle Word [W]rap" })
map('i', '<A-j>', '<Esc><CMD>move .+1<CR>==gi', { desc = 'Move Text Up and Down' })
map('i', '<A-k>', '<Esc><CMD>move .-2<CR>==gi', { desc = 'Move Text Up and Down' })
map('x', '<A-j>', "<CMD>move '>+1<CR>gv-gv", { desc = 'Move Text Up and Down' })
map('x', '<A-k>', "<CMD>move '<-2<CR>gv-gv", { desc = 'Move Text Up and Down' })
map('n', '<leader>xa', ":%bd|e#|bd#<CR>", { desc = "[X]Close [A]ll buffers but this one" })
map("n", "<leader>1", ":ConfigReload<CR> <BAR> :Mason<CR>", { desc = "Reload config" })
map("n", "<leader>2", ":e ~/.config/nvim/init.lua<CR>", { desc = "Edit nvim init.lua file" })
