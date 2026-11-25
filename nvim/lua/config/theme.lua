-- Aplica el tema activo y reacciona a los cambios hechos con `theme set`.
local M = {}

local theme_dir = vim.fn.expand("~/.config/theme")
local current_dir = theme_dir .. "/current"
local fallback = { colorscheme = "gruvbox", background = "dark", overrides = {} }
local watcher

local function load_theme()
  local chunk = loadfile(current_dir .. "/nvim.lua")
  if not chunk then
    return fallback
  end
  local ok, theme = pcall(chunk)
  if not ok or type(theme) ~= "table" then
    return fallback
  end
  return theme
end

function M.apply()
  local theme = load_theme()
  vim.o.background = theme.background or "dark"

  local colorscheme = theme.colorscheme or "gruvbox"
  if not pcall(vim.cmd.colorscheme, colorscheme) then
    pcall(vim.cmd.colorscheme, "gruvbox")
    vim.notify("[theme] colorscheme no disponible: " .. colorscheme, vim.log.levels.WARN)
  end

  for group, attrs in pairs(theme.overrides or {}) do
    vim.api.nvim_set_hl(0, group, attrs)
  end
end

function M.watch()
  if watcher then
    return
  end

  vim.fn.mkdir(theme_dir, "p")
  watcher = (vim.uv or vim.loop).new_fs_event()
  if not watcher then
    return
  end

  local ok = pcall(function()
    watcher:start(theme_dir, {}, vim.schedule_wrap(function()
      vim.defer_fn(M.apply, 100)
    end))
  end)
  if not ok then
    watcher = nil
  end
end

vim.api.nvim_create_user_command("ThemeReload", function()
  M.apply()
end, { desc = "Recargar el tema activo", force = true })

return M
