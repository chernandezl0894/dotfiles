return {
  "HiPhish/rainbow-delimiters.nvim",
  event = "BufReadPost",
  config = function()
    require("rainbow-delimiters.setup").setup({})
  end,
}
