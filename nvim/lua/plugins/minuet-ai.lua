return {
  {
    'milanglacier/minuet-ai.nvim',
    config = function()
      local has_key = function(env_name)
        local value = vim.env[env_name]
        return value ~= nil and value ~= ''
      end

      -- Example:
      -- Put in ~/.zshrc or ~/.bashrc: export OPENROUTER_API_KEY="your_key"
      local provider_env = {
        codestral = 'CODESTRAL_API_KEY',
        openai_compatible = 'OPENROUTER_API_KEY',
        openai = 'OPENAI_API_KEY',
        gemini = 'GEMINI_API_KEY',
        claude = 'ANTHROPIC_API_KEY',
        openai_fim_compatible = 'DEEPSEEK_API_KEY',
      }

      local fallback_order = {
        'codestral',
        'openai_compatible',
        'openai',
        'gemini',
        'claude',
        'openai_fim_compatible',
      }

      local preferred_provider = 'codestral'
      local provider = nil

      if has_key(provider_env[preferred_provider]) then
        provider = preferred_provider
      else
        for _, candidate in ipairs(fallback_order) do
          if has_key(provider_env[candidate]) then
            provider = candidate
            break
          end
        end
      end

      if not provider then
        vim.notify(
          'Minuet(AI Autocomplete) disabled: set CODESTRAL_API_KEY, OPENROUTER_API_KEY, OPENAI_API_KEY, GEMINI_API_KEY, ANTHROPIC_API_KEY, or DEEPSEEK_API_KEY in ~/.zshrc and restart Neovim.',
          vim.log.levels.WARN
        )
        return
      end

      require('minuet').setup {
        provider = provider,
        request_timeout = 3.5,
        throttle = 2500,
        debounce = 500,
        n_completions = 1,
        provider_options = {
          openai_compatible = {
            api_key = 'OPENROUTER_API_KEY',
            model = 'qwen/qwen3-coder:free',
            name = 'Openrouter',
            end_point = 'https://openrouter.ai/api/v1/chat/completions',
            stream = true,
            optional = {
              max_tokens = 1024,
              provider = {
                sort = 'throughput',
              },
            },
          },
          codestral = {
            model = 'codestral-latest',
            end_point = 'https://codestral.mistral.ai/v1/fim/completions',
            api_key = 'CODESTRAL_API_KEY',
            stream = true,
            optional = {
              stop = { '\n\n' },
              max_tokens = nil,
            },
          },
          openai = {
            api_key = 'OPENAI_API_KEY',
            model = 'gpt-4.1-mini',
            end_point = 'https://api.openai.com/v1/chat/completions',
            stream = true,
            optional = {
              max_tokens = 256,
            },
          },
          gemini = {
            api_key = 'GEMINI_API_KEY',
            model = 'gemini-2.0-flash',
            end_point = 'https://generativelanguage.googleapis.com/v1beta/models',
            stream = true,
            optional = {
              generationConfig = {
                maxOutputTokens = 256,
              },
            },
          },
          claude = {
            api_key = 'ANTHROPIC_API_KEY',
            model = 'claude-haiku-4.5',
            end_point = 'https://api.anthropic.com/v1/messages',
            stream = true,
            max_tokens = 256,
          },
          openai_fim_compatible = {
            api_key = 'DEEPSEEK_API_KEY',
            model = 'deepseek-chat',
            name = 'Deepseek',
            end_point = 'https://api.deepseek.com/beta/completions',
            stream = true,
            optional = {
              max_tokens = 256,
              stop = { '\n\n' },
            },
          },
        },
      }
    end,
  },
}
