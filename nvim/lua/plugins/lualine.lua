return {
  'nvim-lualine/lualine.nvim',
  dependencies = {
    'nvim-tree/nvim-web-devicons',
  },
  config = function()
    local lualine = require "lualine"
    local function file_icon()
      if not vim.g.have_nerd_font then
        return ''
      end

      local filename = vim.fn.expand('%:t')
      local extension = vim.fn.expand('%:e')
      local icon = require('nvim-web-devicons').get_icon(filename, extension, { default = true })
      return icon
    end

    -- Show the register being recorded; empty otherwise.
    local function recording()
      local register = vim.fn.reg_recording()
      if register == '' then
        return ''
      end
      return 'recording @' .. register
    end

    -- Conteo de palabras; "" cuando el plugin no está o el ft no aplica.
    local function wordcount()
      local ok, wc = pcall(require, 'wordcount')
      if not ok then
        return ''
      end
      return wc.statusline()
    end

    lualine.setup({
      options = {
        icons_enabled = true,
        theme = 'auto',
        component_separators = { left = '', right = '' },
        section_separators = { left = '', right = '' },
        disabled_filetypes = {
          statusline = {},
          winbar = {},
        },
        ignore_focus = {},
        always_divide_middle = true,
        globalstatus = false,
        refresh = {
          statusline = 1000,
          tabline = 1000,
          winbar = 1000,
        }
      },
      sections = {
        lualine_a = { 'mode' },
        lualine_b = { 'branch', 'diff' },
        lualine_c = { file_icon, { 'filename', path = 1 } },
        lualine_x = { 'searchcount', 'selectioncount', wordcount, recording, 'diagnostics', 'lsp_status', 'filetype' },
        lualine_y = { 'progress' },
        lualine_z = { 'location' }
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { 'filename' },
        lualine_x = { 'location' },
        lualine_y = {},
        lualine_z = {}
      },
      tabline = {},
      winbar = {},
      inactive_winbar = {},
      extensions = {}
    })
  end
}
