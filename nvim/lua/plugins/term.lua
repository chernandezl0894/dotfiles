return {
  "akinsho/toggleterm.nvim",
  config = function()
    local term = require "toggleterm"
    local Terminal = require "toggleterm.terminal".Terminal
    local map = vim.keymap.set

    term.setup({
      size = 20,
      open_mapping = "<leader>`",
      shade_terminals = true,
      direction = "horizontal",
      persist_size = true,
      autochdir = true,
      start_in_insert = true,
      float_opts = {
        border = "curved",
        winblend = 0,
        title_pos = "center",
      },
    })

    local function create_terminal(cmd, extra)
      local opts = {
        cmd = cmd,
        hidden = true,
        direction = "horizontal",
        size = 20,
        -- Keep the output visible after the command exits.
        close_on_exit = false,
      }

      return Terminal:new(vim.tbl_extend("force", opts, extra or {}))
    end

    -- High counts keep terminals 1-5 free for the generic shortcuts.
    local make_default = create_terminal("make", { count = 21, display_name = "make" })
    local make_clean = create_terminal("make clean", { count = 22, display_name = "make clean" })
    local make_run = create_terminal("make run", { count = 23, display_name = "make run" })

    vim.cmd([[
      set makeprg=make
      set errorformat=%f:%l:%m
    ]])

    -- Dedicated terminals for each orientation.
    local float_term = Terminal:new({ count = 11, direction = "float", hidden = true, display_name = "float" })
    local horizontal_term = Terminal:new({ count = 12, direction = "horizontal", size = 20, hidden = true, display_name = "shell" })
    local vertical_term = Terminal:new({ count = 13, direction = "vertical", hidden = true, display_name = "vertical" })

    -- Terminal management.
    map("n", "<leader>tt", function()
      float_term:toggle()
    end, { desc = "Terminal flotante" })
    map("n", "<leader>th", function()
      horizontal_term:toggle()
    end, { desc = "Terminal horizontal" })
    map("n", "<leader>tv", function()
      vertical_term:toggle()
    end, { desc = "Terminal vertical" })
    map("n", "<leader>tN", "<cmd>TermNew<cr>", { desc = "Nueva terminal" })
    map("n", "<leader>tA", function()
      term.toggle_all()
    end, { desc = "Alternar todas las terminales" })

    for i = 1, 5 do
      map("n", "<leader>t" .. i, function()
        term.toggle(i)
      end, { desc = "Terminal " .. i })
    end

    -- Send code/commands to terminal 1, or to the terminal in the count.
    local function send_lines(kind)
      local count = vim.v.count
      if count == 0 then
        count = 1
      end
      term.send_lines_to_terminal(kind, true, { args = count })
    end

    map("n", "<leader>t.", function()
      send_lines("single_line")
    end, { desc = "Enviar línea al terminal" })
    map("v", "<leader>t.", function()
      send_lines("visual_selection")
    end, { desc = "Enviar selección al terminal" })

    -- Makefile shortcuts.
    map("n", "<leader>m", function()
      make_default:toggle()
    end, { desc = "Run Makefile default command and open terminal" })
    map("n", "<leader>mc", function()
      make_clean:toggle()
    end, { desc = "Run Makefile clean command and open terminal" })
    map("n", "<leader>mr", function()
      make_run:toggle()
    end, { desc = "Run Makefile run command and open terminal" })

    -- Lazygit in a floating terminal, when installed.
    local lazygit
    map("n", "<leader>gg", function()
      if vim.fn.executable("lazygit") == 0 then
        vim.notify("lazygit no está instalado", vim.log.levels.WARN)
        return
      end

      lazygit = lazygit
        or Terminal:new({
          count = 31,
          cmd = "lazygit",
          dir = "git_dir",
          hidden = true,
          direction = "float",
          display_name = "lazygit",
          close_on_exit = true,
        })
      lazygit:toggle()
    end, { desc = "Lazygit (float)" })
  end,
}
