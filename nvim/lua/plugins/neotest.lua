local function python_path()
  for _, name in ipairs({ ".venv", "venv", ".virtualenv" }) do
    local path = vim.fn.getcwd() .. "/" .. name .. "/bin/python"
    if vim.fn.executable(path) == 1 then
      return path
    end
  end

  return vim.fn.exepath("python3")
end

return {
  "nvim-neotest/neotest",
  event = "VeryLazy",
  dependencies = {
    "nvim-neotest/nvim-nio",
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    "nvim-neotest/neotest-python",
  },
  config = function()
    require("neotest").setup({
      adapters = {
        require("neotest-python")({
          dap = { justMyCode = false },
          python = python_path,
        }),
      },
    })

    local neotest = require("neotest")
    local map = function(keys, func, desc)
      vim.keymap.set("n", keys, func, { desc = desc })
    end

    map("<leader>tn", function()
      neotest.run.run()
    end, "[T]est [N]earest")

    map("<leader>tf", function()
      neotest.run.run(vim.fn.expand("%"))
    end, "[T]est [F]ile")

    map("<leader>ts", function()
      neotest.run.run({ suite = true })
    end, "[T]est [S]uite")

    map("<leader>tl", function()
      neotest.run.run_last()
    end, "[T]est [L]ast")

    map("<leader>td", function()
      neotest.run.run({ strategy = "dap" })
    end, "[T]est [D]ebug nearest")

    map("<leader>to", function()
      neotest.output.open({ enter = true, auto_close = true })
    end, "[T]est [O]utput")

    map("<leader>tS", function()
      neotest.summary.toggle()
    end, "[T]est [S]ummary")
  end,
}
