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
  "mfussenegger/nvim-dap",
  event = "VeryLazy",
  dependencies = {
    "jay-babu/mason-nvim-dap.nvim",
  },
  config = function()
    local dap = require("dap")

    dap.configurations.python = dap.configurations.python or {}

    table.insert(dap.configurations.python, 1, {
      type = "python",
      request = "launch",
      name = "Python: Current file",
      program = "${file}",
      cwd = "${workspaceFolder}",
      pythonPath = python_path,
      justMyCode = false,
      console = "integratedTerminal",
    })

    table.insert(dap.configurations.python, 1, {
      type = "python",
      request = "launch",
      name = "FastAPI: uvicorn",
      module = "uvicorn",
      args = function()
        local target = vim.fn.input("ASGI app (module:attr): ", "app.main:app")
        return { target, "--host", "127.0.0.1", "--port", "8000" }
      end,
      cwd = "${workspaceFolder}",
      pythonPath = python_path,
      justMyCode = false,
      console = "integratedTerminal",
    })
  end,
}
