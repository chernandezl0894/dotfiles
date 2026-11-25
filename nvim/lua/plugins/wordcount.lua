-- Plugin local en desarrollo. En máquinas sin ~/projects/wordcount.nvim
-- se omite por completo: no hay error ni intento de clonarlo.
local dev_dir = vim.fn.expand("~/projects/wordcount.nvim")

return {
  "wordcount.nvim",
  dev = true,
  enabled = function()
    return (vim.uv or vim.loop).fs_stat(dev_dir) ~= nil
  end,
  opts = {
    -- Tu velocidad de lectura en palabras por minuto.
    -- Cámbialo a 120 para ver cómo se mueve el "min" en la statusline.
    wpm = 180,
  },
}
