return {
  {
    'milanglacier/minuet-ai.nvim',
    config = function()
      -- NOTE: Add CODESTRAL_API_KEY to env variables or bashrc/zshrc
      -- NOTE: You can change the llm provider but we use codestral for now since it is free
      local api_key = vim.env.CODESTRAL_API_KEY

      if not api_key or api_key == '' then
        vim.notify('⚠️ CODESTRAL_API_KEY not set. Skipping Minuet setup.', vim.log.levels.WARN)
        return
      end

      require('minuet').setup {
        chunk_completion = true, -- REQUIRED for multiline suggestions
        max_lines = 20, -- Allow up to 20 lines generated
        max_tokens = 1024, -- Keep your existing upper limit
        debounce_ms = 120, -- Faster UI responsiveness
        suffix_pct = 0.2, -- Gives model future context (better blocks)
        provider_options = {
          codestral = {
            model = 'codestral-latest',
            end_point = 'https://codestral.mistral.ai/v1/fim/completions',
            stream = true,
            optional = {
              max_tokens = 1024,

              -- stop = { '\n\n' }, But Codestral’s FIM API sometimes returns completions wrapped in objects, not plain text. Try removing or simplifying stop, so Minuet doesn’t choke:
            },
          },
          -- openai_compatible = {
          --   open_router_key = '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',
          --   end_point = 'https://openrouter.ai/api/v1/chat/completions',
          --   model = 'x-ai/grok-4.0-fast',
          --   name = 'Openrouter',
          --   optional = {
          --     max_tokens = 1024, -- or whatever you want
          --     top_p = 0.9,
          --     provider = {
          --       sort = 'throughput',
          --     },
          --   },
          -- },
        },
      }
    end,
  },
}
