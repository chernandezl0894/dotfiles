-- Lector TTS local para WSL: usa las voces de Windows vía powershell.exe.
-- En máquinas sin el repo o sin WSL, lazy lo omite por completo.
local dev_dir = vim.fn.expand("~/projects/tts.nvim")

local function run(fn)
  return function()
    local ok, tts = pcall(require, "tts")
    if not ok then
      return
    end
    fn(tts)
  end
end

return {
  "tts.nvim",
  dev = true,
  enabled = function()
    return (vim.uv or vim.loop).fs_stat(dev_dir) ~= nil
  end,
  cmd = {
    "TtsRead",
    "TtsToggle",
    "TtsStop",
    "TtsNext",
    "TtsPrev",
    "TtsSpeed",
    "TtsVoice",
    "TtsStatus",
    "TtsDoctor",
  },
  keys = {
    { "<leader>rr", run(function(t) t.toggle() end), desc = "Leer en voz alta / pausar" },
    { "<leader>rs", run(function(t) t.stop() end), desc = "Detener lectura" },
    { "<leader>rn", run(function(t) t.next() end), desc = "Siguiente párrafo" },
    { "<leader>rp", run(function(t) t.prev() end), desc = "Párrafo anterior" },
    { "<leader>r+", run(function(t) t.speed(2) end), desc = "Leer más rápido" },
    { "<leader>r-", run(function(t) t.speed(-2) end), desc = "Leer más lento" },
    { "<leader>rv", run(function(t) t.pick_voice() end), desc = "Cambiar voz" },
  },
  opts = {
    backend = "edge",
    voice = "es-MX-DaliaNeural",
    sapi_voice = "Microsoft Sabina Desktop",
    volume = 80,
  },
}
