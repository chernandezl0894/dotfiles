local map = function(mode, shortcut, cmd, options)
  vim.keymap.set(mode, shortcut, cmd, options or {})
end

return {
  "rcarriga/nvim-dap-ui",
  event = "VeryLazy",
  dependencies = {
    "mfussenegger/nvim-dap",
    "nvim-neotest/nvim-nio",
    -- "theHamsta/nvim-dap-virtual-text"
  },
  config = function()
    local dap = require "dap"
    local dapui = require "dapui"

    -- Nerd Font icons for breakpoints and the current frame.
    -- nr2char keeps the glyphs readable and avoids encoding issues.
    local function sign_text(codepoint, fallback)
      if not vim.g.have_nerd_font then
        return fallback
      end
      return vim.fn.nr2char(codepoint)
    end

    -- Reuse diagnostic colors so the signs work with any colorscheme.
    vim.api.nvim_set_hl(0, "DapBreakpoint", { link = "DiagnosticError" })
    vim.api.nvim_set_hl(0, "DapBreakpointCondition", { link = "DiagnosticWarn" })
    vim.api.nvim_set_hl(0, "DapBreakpointRejected", { link = "DiagnosticError" })
    vim.api.nvim_set_hl(0, "DapLogPoint", { link = "DiagnosticInfo" })
    vim.api.nvim_set_hl(0, "DapStopped", { link = "DiagnosticHint" })

    local signs = {
      DapBreakpoint = { text = sign_text(0xF111, "B"), texthl = "DapBreakpoint" },
      DapBreakpointCondition = { text = sign_text(0xF059, "C"), texthl = "DapBreakpointCondition" },
      DapBreakpointRejected = { text = sign_text(0xF057, "R"), texthl = "DapBreakpointRejected" },
      DapLogPoint = { text = sign_text(0xF0EB, "L"), texthl = "DapLogPoint" },
      DapStopped = { text = sign_text(0xF144, "→"), texthl = "DapStopped", linehl = "debugPC" },
    }
    for name, sign in pairs(signs) do
      vim.fn.sign_define(name, sign)
    end

    dapui.setup()

    dap.listeners.after.event_initialized.dapui_config = function()
      dapui.open()
    end

    dap.listeners.before.event_terminated.dapui_config = function()
      dapui.close()
    end

    dap.listeners.before.event_exited.dapui_config = function()
      dapui.close()
    end

    -- Session control.
    map("n", "<F5>", dap.continue, { desc = "DAP: Continue / Start" })
    map("n", "<F9>", dap.toggle_breakpoint, { desc = "DAP: Toggle breakpoint" })
    map("n", "<F10>", dap.step_over, { desc = "DAP: Step over" })
    map("n", "<F11>", dap.step_into, { desc = "DAP: Step into" })
    map("n", "<F12>", dap.step_out, { desc = "DAP: Step out" })
    map("n", "<leader>b", dap.toggle_breakpoint, { desc = "DAP: Toggle breakpoint" })
    map("n", "<leader>B", function()
      dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
    end, { desc = "DAP: Conditional breakpoint" })
    map("n", "<leader>lp", function()
      dap.set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
    end, { desc = "DAP: Log point" })
    map("n", "<leader>dt", dap.terminate, { desc = "DAP: Terminate session" })
    map("n", "<leader>dR", dap.restart, { desc = "DAP: Restart session" })

    -- UI and inspection.
    map("n", "<leader>du", dapui.toggle, { desc = "DAP: Toggle UI" })
    map("n", "<leader>de", dapui.eval, { desc = "DAP: Evaluate expression" })
    map("v", "<leader>de", dapui.eval, { desc = "DAP: Evaluate selection" })
    map("n", "<leader>dr", dap.repl.toggle, { desc = "DAP: Toggle REPL" })
    map("n", "<leader>dl", dap.run_last, { desc = "DAP: Run last" })
  end,
}
