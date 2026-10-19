return {
  "WhoIsSethDaniel/mason-tool-installer.nvim",
  lazy = false,
  dependencies = {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    "jay-babu/mason-nvim-dap.nvim",
  },
  config = function()
    local ok, installer = pcall(require, "mason-tool-installer")
    if not ok then
      vim.notify("mason-tool-installer failed to load", vim.log.levels.WARN)
      return
    end

    installer.setup({
      ensure_installed = {
        "prettier",
        "ruff",
        "goimports",
        "clang-format",
        "stylua",
        "eslint_d",
        "stylelint",
      },
    })
  end,
}
