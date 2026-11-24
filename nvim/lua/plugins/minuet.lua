-- Manual AI completion with Minuet.
--
-- Default: local Ollama model, triggered only with <A-]>.
-- Switch to DeepSeek at runtime:
--   :Minuet change_preset deepseek
-- Or start Neovim with:
--   MINUET_PRESET=deepseek DEEPSEEK_API_KEY=... nvim
--
-- Optional overrides:
--   MINUET_OLLAMA_MODEL, MINUET_OLLAMA_ENDPOINT
--   MINUET_DEEPSEEK_MODEL, MINUET_DEEPSEEK_ENDPOINT

local function ollama()
  return {
    provider = "openai_fim_compatible",
    n_completions = 1,
    context_window = 512,
    throttle = 300,
    debounce = 100,
    -- Local models can take a while on the first request (cold start).
    request_timeout = 20,
    provider_options = {
      openai_fim_compatible = {
        -- Ollama does not need a real key; Minuet just needs a non-empty
        -- environment variable name.
        api_key = "TERM",
        name = "Ollama",
        end_point = vim.env.MINUET_OLLAMA_ENDPOINT or "http://localhost:11434/v1/completions",
        model = vim.env.MINUET_OLLAMA_MODEL or "qwen2.5-coder:1.5b",
        optional = {
          max_tokens = 96,
          top_p = 0.9,
        },
      },
    },
  }
end

local function deepseek()
  return {
    provider = "openai_compatible",
    n_completions = 1,
    context_window = 4096,
    throttle = 1000,
    debounce = 300,
    request_timeout = 8,
    provider_options = {
      openai_compatible = {
        api_key = "DEEPSEEK_API_KEY",
        name = "DeepSeek",
        end_point = vim.env.MINUET_DEEPSEEK_ENDPOINT or "https://api.deepseek.com/v1/chat/completions",
        model = vim.env.MINUET_DEEPSEEK_MODEL or "deepseek-chat",
        optional = {
          max_tokens = 128,
          top_p = 0.9,
          temperature = 0.2,
        },
      },
    },
  }
end

local presets = {
  ["local"] = ollama(),
  deepseek = deepseek(),
}

local base = {
  notify = "warn",
  virtualtext = {
    -- Empty on purpose: no automatic requests. Press <A-]> to ask.
    auto_trigger_ft = {},
    show_on_completion_menu = false,
    keymap = {
      accept = "<A-A>",
      accept_line = "<A-a>",
      accept_word = "<A-w>",
      accept_n_lines = "<A-z>",
      next = "<A-]>",
      prev = "<A-[>",
      dismiss = "<A-e>",
    },
  },
  presets = presets,
}

return {
  "milanglacier/minuet-ai.nvim",
  event = "VeryLazy",
  config = function()
    local name = vim.env.MINUET_PRESET or "local"
    local selected = presets[name]

    if not selected then
      vim.notify("Unknown MINUET_PRESET '" .. name .. "'; using local", vim.log.levels.WARN)
      selected = presets["local"]
    end

    if name == "deepseek" and vim.env.DEEPSEEK_API_KEY == nil then
      vim.notify("MINUET_PRESET=deepseek but DEEPSEEK_API_KEY is not set", vim.log.levels.WARN)
    end

    require("minuet").setup(vim.tbl_deep_extend("force", {}, base, selected))
  end,
}
