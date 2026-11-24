return {
  "HiPhish/rainbow-delimiters.nvim",
  -- v0.12.0 is the last release that supports Neovim 0.10; newer commits
  -- assume the 0.11+ treesitter match API.
  version = "v0.12.0",
  event = "BufReadPost",
  config = function()
    require("rainbow-delimiters.setup").setup({})
  end,
}
