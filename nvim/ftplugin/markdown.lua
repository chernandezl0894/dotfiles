-- Perfil de lectura para Markdown: prosa sin ruido visual.

local function apply_reading(on)
  local o = vim.opt_local

  -- Ajuste suave al ancho de la ventana, con sangría colgante.
  o.wrap = on
  o.linebreak = on
  o.breakindent = on

  -- Fuera números, signos, listchars (↵ · ▸) y corrector.
  o.number = not on
  o.relativenumber = not on
  o.signcolumn = on and "no" or "yes"
  o.list = not on
  o.spell = false

  o.colorcolumn = ""
end

apply_reading(true)

-- Estado "crudo" por defecto: sin conceal. render-markdown pone
-- conceallevel=3 mientras está renderizando y lo restaura al desactivarse.
vim.opt_local.conceallevel = 0
vim.opt_local.concealcursor = ""

-- <leader>ur: alterna lectura / edición en el mismo buffer.
vim.keymap.set("n", "<leader>ur", function()
  local on = not vim.opt_local.wrap:get()
  apply_reading(on)
  vim.notify("Markdown: lectura " .. (on and "ON" or "OFF"))
end, { buffer = true, desc = "Alternar modo lectura" })

-- <leader>uh: salta a cualquier encabezado del documento.
vim.keymap.set("n", "<leader>uh", function()
  local items = {}
  for lnum, line in ipairs(vim.api.nvim_buf_get_lines(0, 0, -1, false)) do
    local hashes, text = line:match("^(#+)%s+(.+)$")
    if hashes then
      items[#items + 1] = { label = text, level = #hashes, lnum = lnum }
    end
  end

  if #items == 0 then
    vim.notify("Este buffer no tiene encabezados", vim.log.levels.INFO)
    return
  end

  vim.ui.select(items, {
    prompt = "Encabezados",
    format_item = function(item)
      return string.rep("  ", item.level - 1) .. item.label
    end,
  }, function(item)
    if not item then
      return
    end
    vim.cmd("normal! m'") -- marca para volver con <C-o>
    vim.api.nvim_win_set_cursor(0, { item.lnum, 0 })
    vim.cmd("normal! zz")
  end)
end, { buffer = true, desc = "Ir a encabezado" })

-- Oculta el frontmatter YAML (libro, autor, tags...) al abrir el archivo.
local function fold_frontmatter()
  local buf = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(buf, 0, math.min(30, vim.api.nvim_buf_line_count(buf)), false)

  if lines[1] ~= "---" then
    return
  end

  for i = 2, #lines do
    if lines[i] == "---" then
      vim.opt_local.foldmethod = "manual"
      vim.cmd(("1,%dfold"):format(i))
      return
    end
  end
end

fold_frontmatter()
