return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    delay = 300,
    spec = {
      { "<leader>d", group = "Debug" },
      { "<leader>g", group = "Git" },
      { "<leader>h", group = "Git hunks" },
      { "<leader>s", group = "Search" },
      { "<leader>t", group = "Terminal / Tests" },
    },
  },
}
