-- Colorschemes disponibles. Ambos se cargan (son ligeros) para que
-- `theme set` pueda cambiar en caliente sin reiniciar Neovim.
--
-- El aplicador vive en el último colorscheme (menor priority) para que
-- corra después de que todos estén en el runtimepath. Así también se
-- mantiene el fallback a gruvbox si el tema pide un colorscheme ausente.
return {
  {
    "morhetz/gruvbox",
    lazy = false,
    priority = 1001,
  },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    config = function()
      local theme = require("config.theme")
      theme.apply()
      theme.watch()
    end,
  },
}
