return {
  "morhetz/gruvbox",
  lazy = false,
  priority = 1000,
  config = function()
    local theme = require("config.theme")
    theme.apply()
    theme.watch()
  end,
}
