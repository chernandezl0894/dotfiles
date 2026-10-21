local is_nvim_11 = vim.fn.has("nvim-0.11") == 1

-- Find the virtual environment used by a Python project.
local function find_venv(root_dir)
  for _, name in ipairs({ ".venv", "venv", ".virtualenv" }) do
    if vim.fn.isdirectory(root_dir .. "/" .. name) == 1 then
      return root_dir, name
    end
  end
end

return {
  'neovim/nvim-lspconfig',
  version = is_nvim_11 and nil or 'v2.*',
  dependencies = {
    'saghen/blink.cmp',
    'williamboman/mason.nvim',
    'williamboman/mason-lspconfig.nvim',
    'folke/neodev.nvim',
  },
  config = function()
    local capabilities = require('blink.cmp').get_lsp_capabilities()
    local lsp = require("lspconfig")
    local on_attach = function(_, bufnr)
      local map = function(keys, func, desc)
        vim.keymap.set('n', keys, func, { buffer = bufnr, desc = 'LSP -> ' .. desc })
      end

      map('K', vim.lsp.buf.hover, 'Hover Documentation')
      map('<Leader>rn', vim.lsp.buf.rename, '[R]e[N]ame')
      map('<Leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
      map('<Leader>e', vim.diagnostic.open_float, 'Open Float Diagnostic')
      map('[d', vim.diagnostic.goto_prev, '[[][D] Goto Previous')
      map(']d', vim.diagnostic.goto_next, '[[][D] Goto Next')
      map('<Leader>f', function()
        local ok, conform = pcall(require, "conform")
        if ok then
          conform.format({ async = true, lsp_fallback = true })
        else
          vim.lsp.buf.format({ async = true })
        end
        vim.notify('Formatted successfully', "info")
      end, 'Format buffer')
    end

    require('mason-lspconfig').setup({
      ensure_installed = {
        'lua_ls',
        'html',
        'cssls',
        'tailwindcss',
        'emmet_ls',
        'pyright',
        'rust_analyzer',
        'gopls',
        'ols',
        'zls',
        'clangd',
        'ts_ls',
        'ruff',
      },
      automatic_installation = false,
      automatic_enable = is_nvim_11 or false,
    })

    require('neodev').setup()

    lsp.lua_ls.setup({
      on_attach = on_attach,
      capabilities = capabilities,
      settings = {
        Lua = {
          telemetry = { enable = false },
          workspace = { checkThirdParty = false },
        },
      },
    })

    lsp.ts_ls.setup({
      on_attach = on_attach,
      capabilities = capabilities,
      filetypes = {
        'javascript',
        'javascriptreact',
        'javascript.jsx',
        'typescript',
        'typescriptreact',
        'typescript.tsx',
      },
    })

    lsp.emmet_ls.setup({
      on_attach = on_attach,
      capabilities = capabilities,
      filetypes = { "html" },
    })

    lsp.pyright.setup({
      on_attach = on_attach,
      capabilities = capabilities,
      on_new_config = function(new_config, new_root_dir)
        local venv_root, venv_name = find_venv(new_root_dir)
        if not venv_root then
          return
        end

        new_config.settings = new_config.settings or {}
        new_config.settings.python = new_config.settings.python or {}
        new_config.settings.python.venvPath = venv_root
        new_config.settings.python.venv = venv_name
      end,
      settings = {
        python = {
          analysis = {
            autoSearchPaths = true,
            useLibraryCodeForTypes = true,
            -- Ruff owns import organization.
            disableOrganizeImports = true,
          },
        },
      },
    })

    lsp.ruff.setup({
      on_attach = on_attach,
      capabilities = capabilities,
    })

    lsp.clangd.setup({
      on_attach = on_attach,
      capabilities = capabilities,
    })

    lsp.rust_analyzer.setup({
      on_attach = on_attach,
      capabilities = capabilities,
    })

    lsp.gopls.setup({
      on_attach = on_attach,
      capabilities = capabilities,
      settings = {
        gopls = {
          -- Extra diagnostics on top of the compiler errors.
          analyses = {
            unusedwrite = true,
            nilness = true,
            embeddableStruct = true,
            unusedparams = true,
            unusedvariable = true,
          },
          staticcheck = false,
          -- Code lenses: "go generate", "go mod tidy" and run test/benchmark.
          codelenses = {
            generate = true,
            tidy = true,
            test = true,
          },
          -- gofumpt is not installed, keep goimports as the formatter.
          gofumpt = false,
        },
      },
    })

    lsp.ols.setup({
      on_attach = on_attach,
      capabilities = capabilities,
    })

    lsp.zls.setup({
      on_attach = on_attach,
      capabilities = capabilities,
    })

    lsp.html.setup({
      on_attach = on_attach,
      capabilities = capabilities,
    })

    lsp.cssls.setup({
      on_attach = on_attach,
      capabilities = capabilities,
    })

    lsp.tailwindcss.setup({
      on_attach = on_attach,
      capabilities = capabilities,
    })
  end,
}
