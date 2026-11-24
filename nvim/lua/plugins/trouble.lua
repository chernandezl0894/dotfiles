local function trouble(mode)
  return function()
    require("trouble").toggle(mode)
  end
end

return {
  "folke/trouble.nvim",
  cmd = "Trouble",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = {},
  keys = {
    { "<leader>xx", trouble("diagnostics"), desc = "Diagnostics" },
    { "<leader>xX", trouble("document_diagnostics"), desc = "Buffer diagnostics" },
    { "<leader>xs", trouble("symbols"), desc = "Symbols" },
    { "<leader>xr", trouble("lsp_references"), desc = "LSP references" },
    { "<leader>xl", trouble("loclist"), desc = "Location list" },
    { "<leader>xq", trouble("quickfix"), desc = "Quickfix list" },
  },
}
