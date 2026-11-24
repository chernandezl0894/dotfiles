return {
  'nvim-telescope/telescope.nvim',
  tag = '0.1.8',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons',
    { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
    'nvim-telescope/telescope-ui-select.nvim',
  },
  config = function()
    local telescope = require "telescope"
    local builtin = require "telescope.builtin"
    local actions = require "telescope.actions"
    local function map(mode, l, r, opts)
      vim.keymap.set(mode, l, r, opts)
    end

    telescope.setup({
      defaults = {
        file_ignore_patterns = {
          '.git/',
          'node_modules/',
          'vendor/',
          'dist/',
          'build/',
          'logs/',
          'storage/logs/',
        },
        color_devicons = vim.g.have_nerd_font,
        winblend = 0,
        layout_strategy = 'vertical',
        path_display = { 'absolute' },
        layout_config = {
          preview_cutoff = 9999,
          prompt_position = 'top',
          width = 0.5,
          height = 0.8,
          -- preview_width = 0.65,
        },
        previewer = false,
        theme = "dropdown",
        selection_strategy = "reset",
        sorting_strategy = "ascending",
        scroll_strategy = "cycle",
        mappings = {
          i = {
            ['<Esc>'] = actions.close,
            ['<C-n>'] = actions.cycle_history_next,
            ['<C-p>'] = actions.cycle_history_prev,
          },
        },
      },
      pickers = {
        find_files = {
          hidden = true,
          follow = true,
          previewer = false,
          theme = "dropdown",
        },
        live_grep = {
          previewer = false,
        },
        grep_string = {
          hidden = true,
          follow = true,
          previewer = false,
          theme = "dropdown",
        },
        buffers = {
          hidden = true,
          follow = true,
          previewer = false,
          theme = "dropdown",
        },
      },
    })

    pcall(telescope.load_extension, "fzf")
    pcall(telescope.load_extension, "ui-select")

    map('n', 'gd', builtin.lsp_definitions, { desc = '[G]oto [D]efinitions' })
    map('n', 'gr', builtin.lsp_references, { desc = '[G]oto [R]eferences' })
    map('n', 'gI', builtin.lsp_implementations, { desc = '[G]oto [I]mplementations' })
    map('n', 'D', builtin.lsp_type_definitions, { desc = 'Type [D]efinitions' })
    map('n', 'ds', builtin.lsp_document_symbols, { desc = '[D]ocuments [S]ymbols' })
    map('n', '<Leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
    map('n', '<Leader>ss', builtin.live_grep, { desc = '[S]earch Live Grep' })
    map('n', '<Leader>sw', function()
      builtin.grep_string({
        word_match = "-w",
        search = vim.fn.expand("<cword>"),
      })
    end, { desc = '[S]earch Current [W]ord' })
    map('n', '<Leader>sg', builtin.git_status, { desc = '[S]earch [G]it Status' })
    map('n', '<Leader>gl', builtin.git_commits, { desc = '[G]it [L]og' })
    map('n', '<Leader>gL', builtin.git_bcommits, { desc = '[G]it [B]uffer [L]og' })
    map('n', '<Leader>gb', builtin.git_branches, { desc = '[G]it [B]ranches' })
    map('n', '<Leader>gz', builtin.git_stash, { desc = '[G]it [Z]tash' })
    map('n', '<Leader>sb', builtin.buffers, { desc = '[S]earch [B]uffers' })
    map('n', '<Leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
    map('n', '<Leader>sh', builtin.help_tags, { desc = '[S]earch [H]elps' })
    map('n', '<Leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
    map('n', '<C-p>', builtin.git_files, { desc = 'Search Git Files' })
    map('n', '<Leader>sx', function()
      builtin.find_files({
        cwd = vim.fn.stdpath('config')
      })
    end, { desc = '[S]earch [X] Neovim Files' })
  end,
}
