return {
  {
    'sindrets/diffview.nvim',
    cmd = { 'DiffviewOpen', 'DiffviewClose', 'DiffviewFileHistory', 'DiffviewToggleFiles' },
    keys = {
      { '<leader>gd', '<cmd>DiffviewOpen<cr>', desc = 'Git: Diff view (working tree)' },
      { '<leader>gq', '<cmd>DiffviewClose<cr>', desc = 'Git: Close diff view' },
      { '<leader>gh', '<cmd>DiffviewFileHistory %<cr>', desc = 'Git: File history' },
      { '<leader>gH', '<cmd>DiffviewFileHistory<cr>', desc = 'Git: Repo history' },
    },
    opts = {
      enhanced_diff_hl = true,
    },
  },
}
