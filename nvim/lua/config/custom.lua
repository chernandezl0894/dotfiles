-- Insert current time (h:m:s)
local function insert_now()
	local now = os.date("%H:%M:%S")

	vim.api.nvim_put({ now }, "c", true, true)
end

-- insert current date (d/m/Y)
local function insert_today()
	local today = os.date("%d/%m/%Y")

	vim.api.nvim_put({ today }, "c", true, true)
end

-- Set custom options for C/C++ files.
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	pattern = { "*.c", "*.h", "*.cpp", "*.hpp" },
	callback = function()
		vim.opt_local.colorcolumn = "80"
		vim.opt_local.tabstop = 4
		vim.opt_local.shiftwidth = 4
		vim.opt_local.expandtab = true
	end,
})

-- Remove all white space on saving file.
local function trim()
	local save = vim.fn.winsaveview()
	vim.cmd([[%s/\s\+$//e]])
	vim.fn.winrestview(save)
end
vim.api.nvim_create_user_command("Trim", trim, { nargs = 0 })

-- Hightlight on Yank.
vim.api.nvim_create_autocmd("TextYankPost", {
	pattern = "*",
	callback = function()
		vim.highlight.on_yank({ higroup = "IncSearch", timeout = 150 })
	end,
})

vim.keymap.set("i", "<C-n>", insert_now, { desc = "Insert current time (h:m:s)" })
vim.keymap.set("i", "<C-d>", insert_today, { desc = "Insert current date (d/m/Y)" })
