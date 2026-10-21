-- Go indentation is tabs, as mandated by gofmt/gofumpt.
vim.bo.tabstop = 8
vim.bo.shiftwidth = 8
vim.bo.softtabstop = 8
vim.bo.expandtab = false
vim.bo.smartindent = true
vim.bo.commentstring = "// %s"

-- Go has no line length convention, drop the global 80 column guide.
vim.opt_local.colorcolumn = ""
