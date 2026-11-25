local highlight = {
  "Whitespace",
}

return {
  "lukas-reineke/indent-blankline.nvim",
  main = "ibl",
  opts = {
    indent = {
      highlight = highlight,
      char = "¦"
    },
    whitespace = {
      highlight = highlight,
      remove_blankline_trail = false,
    },
    scope = { enabled = false, highlight = "Whitespace" }
  },
}
