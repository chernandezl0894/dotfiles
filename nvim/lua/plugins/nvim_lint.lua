return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local lint = require("lint")

    lint.linters_by_ft = {
      javascript = { "eslint_d" },
      javascriptreact = { "eslint_d" },
      typescript = { "eslint_d" },
      typescriptreact = { "eslint_d" },
      css = { "stylelint" },
      scss = { "stylelint" },
      less = { "stylelint" },
    }

    local augroup = vim.api.nvim_create_augroup("NvimLint", { clear = true })
    vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave" }, {
      group = augroup,
      callback = function()
        lint.try_lint()
      end,
    })
  end,
}
