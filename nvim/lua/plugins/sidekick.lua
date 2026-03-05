return {
  {
    'folke/sidekick.nvim',
    opts = {
      -- Disable NES (requires Copilot LSP which is not configured)
      -- Enable this later if you set up copilot-language-server
      nes = { enabled = false },
      cli = {
        watch = true, -- auto-reload files modified by AI tools
        win = {
          layout = 'right',
          split = {
            width = 80,
          },
        },
        tools = {
          -- Pre-configured tools you have installed
          opencode = {
            cmd = { 'opencode' },
            env = { OPENCODE_THEME = 'system' },
          },
          claude = {
            cmd = { 'claude' },
          },
        },
      },
    },
    keys = {
      -- Toggle CLI terminal
      {
        '<leader>at',
        function()
          require('sidekick.cli').toggle()
        end,
        desc = 'Sidekick Toggle CLI',
        mode = { 'n', 't' },
      },
      -- Select which CLI tool to use
      {
        '<leader>as',
        function()
          require('sidekick.cli').select()
        end,
        desc = 'Sidekick Select CLI',
      },
      -- Close/detach CLI session
      {
        '<leader>ad',
        function()
          require('sidekick.cli').close()
        end,
        desc = 'Sidekick Close CLI',
      },
      -- Send context to CLI
      {
        '<leader>ac',
        function()
          require('sidekick.cli').send { msg = '{this}' }
        end,
        mode = { 'n', 'x' },
        desc = 'Sidekick Send This',
      },
      {
        '<leader>af',
        function()
          require('sidekick.cli').send { msg = '{file}' }
        end,
        desc = 'Sidekick Send File',
      },
      {
        '<leader>av',
        function()
          require('sidekick.cli').send { msg = '{selection}' }
        end,
        mode = { 'x' },
        desc = 'Sidekick Send Selection',
      },
      {
        '<leader>ab',
        function()
          require('sidekick.cli').send { msg = '{buffers}' }
        end,
        desc = 'Sidekick Send Buffers',
      },
      -- Select a prompt from the prompt library
      {
        '<leader>ap',
        function()
          require('sidekick.cli').prompt()
        end,
        mode = { 'n', 'x' },
        desc = 'Sidekick Select Prompt',
      },
    },
  },
}
