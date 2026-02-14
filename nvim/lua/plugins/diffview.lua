return {
  {
    'sindrets/diffview.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    cmd = {
      'DiffviewOpen',
      'DiffviewClose',
      'DiffviewFileHistory',
      'DiffviewToggleFiles',
      'DiffviewFocusFiles',
      'DiffviewRefresh',
    },
    keys = {
      { '<leader>gd', '<cmd>DiffviewOpen<CR>', desc = 'Git [D]iff View' },
      { '<leader>gq', '<cmd>DiffviewClose<CR>', desc = 'Git Diff [Q]uit' },
      { '<leader>gh', '<cmd>DiffviewFileHistory %<CR>', desc = 'Git [H]istory (File)' },
      { '<leader>gH', '<cmd>DiffviewFileHistory<CR>', desc = 'Git [H]istory (Repo)' },
      { '<leader>gf', '<cmd>DiffviewFocusFiles<CR>', desc = 'Git Diff [F]ocus Files' },
      { '<leader>gt', '<cmd>DiffviewToggleFiles<CR>', desc = 'Git Diff [T]oggle Files' },
      { '<leader>gr', '<cmd>DiffviewRefresh<CR>', desc = 'Git Diff [R]efresh' },
    },
    opts = function()
      local actions = require 'diffview.actions'

      return {
        enhanced_diff_hl = false,
        watch_index = false,
        use_icons = vim.g.have_nerd_font,
        view = {
          default = {
            winbar_info = true,
            disable_diagnostics = true,
          },
          file_history = {
            winbar_info = true,
            disable_diagnostics = true,
          },
        },
        default_args = {
          DiffviewFileHistory = { '--max-count=200' },
        },
        file_history_panel = {
          log_options = {
            git = {
              single_file = {
                follow = false,
              },
            },
          },
        },
        file_panel = {
          win_config = {
            width = 42,
          },
        },
        keymaps = {
          view = {
            { 'n', 'q', actions.close, { desc = 'Close diffview' } },
          },
          file_panel = {
            { 'n', 'q', actions.close, { desc = 'Close diffview' } },
          },
          file_history_panel = {
            { 'n', 'q', actions.close, { desc = 'Close diffview' } },
          },
        },
        hooks = {
          diff_buf_read = function(bufnr)
            vim.b[bufnr].diffview_buffer = true
            vim.opt_local.wrap = false
            vim.opt_local.list = false
          end,
        },
      }
    end,
  },
}
