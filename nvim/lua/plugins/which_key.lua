return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    delay = 300,
    spec = {
      { "<leader>d", group = "Debug" },
      { "<leader>g", group = "Git" },
      { "<leader>H", group = "Harpoon" },
      { "<leader>h", group = "Git hunks" },
      { "<leader>q", group = "Sessions" },
      { "<leader>s", group = "Search" },
      { "<leader>t", group = "Terminal / Tests" },
      { "<leader>u", group = "UI" },
      { "<leader>x", group = "Trouble" },
    },
  },
}
