return {
  'lewis6991/gitsigns.nvim',
  config = function()
    local gitsigns = require('gitsigns')
    gitsigns.setup({
      signs = {
        add          = { text = '┃' },
        change       = { text = '┃' },
        delete       = { text = '_' },
        topdelete    = { text = '‾' },
        changedelete = { text = '~' },
        untracked    = { text = '┆' },
      },
      signs_staged = {
        add          = { text = '┃' },
        change       = { text = '┃' },
        delete       = { text = '_' },
        topdelete    = { text = '‾' },
        changedelete = { text = '~' },
        untracked    = { text = '┆' },
      },
      signs_staged_enable = true,
      signcolumn          = true,
      numhl               = true,
      linehl              = false,
      word_diff           = false,
      current_line_blame  = false,
      on_attach = function(bufnr)
        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        map('n', ']c', function()
          if vim.wo.diff then
            vim.cmd.normal({']c', bang = true})
          else
            gitsigns.nav_hunk('next')
          end
        end)

        map('n', '[c', function()
          if vim.wo.diff then
            vim.cmd.normal({'[c', bang = true})
          else
            gitsigns.nav_hunk('prev')
          end
        end)

        map('n', '<Leader>hs', gitsigns.stage_hunk, { desc = "Stage Hunk" })
        map('n', '<Leader>hu', gitsigns.undo_stage_hunk, { desc = "Undo Stage Hunk" })
        map('n', '<Leader>hr', gitsigns.reset_hunk, { desc = "Reset Hunk" })
        map('v', '<Leader>hs', function() gitsigns.stage_hunk {vim.fn.line('.'), vim.fn.line('v')} end)
        map('v', '<Leader>hr', function() gitsigns.reset_hunk {vim.fn.line('.'), vim.fn.line('v')} end)
        map('n', '<Leader>hS', gitsigns.stage_buffer)
        map('n', '<Leader>hp', gitsigns.preview_hunk)
        map('n', '<Leader>hd', gitsigns.diffthis)
        map('n', '<Leader>hD', function() gitsigns.diffthis('~') end)
        map('n', '<Leader>gB', gitsigns.toggle_current_line_blame, { desc = "Toggle Line Blame" })
        map('n', '<Leader>gS', gitsigns.stage_buffer, { desc = "Stage Buffer" })
        map('n', '<Leader>gcc', ':G commit -m "')
        map('n', '<Leader>gpm', ':G push origin main<CR>')
      end,
    })
  end,
}
