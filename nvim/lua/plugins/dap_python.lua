-- Find the Python interpreter used by the current project.
-- Looks for a virtualenv walking up from the current file, then falls back to
-- an activated VIRTUAL_ENV, the working directory and finally python3.
local function find_env()
  local function from_dir(start)
    local dir = vim.fn.fnamemodify(start, ":p:h")
    while dir and dir ~= "" do
      for _, name in ipairs({ ".venv", "venv", ".virtualenv" }) do
        local python = dir .. "/" .. name .. "/bin/python"
        if vim.fn.executable(python) == 1 then
          return python, dir
        end
      end

      local parent = vim.fn.fnamemodify(dir, ":h")
      if parent == dir then
        break
      end
      dir = parent
    end
  end

  local file = vim.api.nvim_buf_get_name(0)
  if file ~= "" then
    local python, root = from_dir(file)
    if python then
      return python, root
    end
  end

  local venv = vim.env.VIRTUAL_ENV
  if venv and venv ~= "" then
    local python = venv .. "/bin/python"
    if vim.fn.executable(python) == 1 then
      return python, vim.fn.getcwd()
    end
  end

  local python, root = from_dir(vim.fn.getcwd() .. "/.")
  if python then
    return python, root
  end

  return vim.fn.exepath("python3"), vim.fn.getcwd()
end

local function python_path()
  return (find_env())
end

local function project_root()
  local _, root = find_env()
  return root
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

    local configs = {
      {
        type = "python",
        request = "launch",
        name = "Python: Current file",
        program = "${file}",
        cwd = project_root,
        pythonPath = python_path,
        console = "integratedTerminal",
        justMyCode = false,
      },
      {
        type = "python",
        request = "launch",
        name = "FastAPI: uvicorn",
        module = "uvicorn",
        args = function()
          local target = vim.fn.input("ASGI app (module:attr): ", "app.main:app")
          return { target, "--host", "127.0.0.1", "--port", "8000" }
        end,
        cwd = project_root,
        pythonPath = python_path,
        console = "integratedTerminal",
        justMyCode = false,
      },
      {
        type = "python",
        request = "attach",
        name = "Python: Attach (debugpy 5678)",
        connect = { host = "127.0.0.1", port = 5678 },
        cwd = project_root,
        justMyCode = false,
      },
    }

    dap.configurations.python = vim.list_extend(configs, dap.configurations.python)
  end,
}
