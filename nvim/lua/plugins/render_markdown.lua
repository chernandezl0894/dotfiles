return {
  "MeanderingProgrammer/render-markdown.nvim",
  ft = { "markdown" },
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons",
  },
  opts = {
    -- No esconder la decoración en la línea del cursor:
    -- esto es lo que producía el salto al moverte por el texto.
    anti_conceal = { enabled = false },
    heading = {
      sign = false,
      width = "block", -- fondo del ancho del texto, no de toda la ventana
    },
    sign = { enabled = false },
  },
  keys = {
    { "<leader>um", "<cmd>RenderMarkdown toggle<cr>", desc = "Toggle markdown render" },
  },
}
