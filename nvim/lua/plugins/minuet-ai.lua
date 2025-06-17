return {
  {
    'milanglacier/minuet-ai.nvim',
    config = function()
      -- NOTE: Setup CODESTRAL_API_KEY in the zshrc or env variables
      require('minuet').setup {
        provider_options = {
          codestral = {
            model = 'codestral-latest',
            end_point = 'https://codestral.mistral.ai/v1/fim/completions',
            stream = true,
            optional = {
              max_tokens = 512,
              stop = { '\n\n' },
            },
          },
        },
      }
    end,
  },
}
