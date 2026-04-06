return {
  {
    'nvim-tree/nvim-tree.lua',
    cmd = { 'NvimTreeToggle', 'NvimTreeFindFileToggle' },
    keys = {
      { '\\', '<cmd>NvimTreeToggle<CR>', desc = 'File Explorer', silent = true },
      { '<leader>e', '<cmd>NvimTreeFindFileToggle<CR>', desc = 'Explorer (Current File)', silent = true },
    },
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
      disable_netrw = true,
      view = { width = 35 },
      renderer = {
        root_folder_label = false,
        indent_markers = { enable = true },
      },
      filters = { dotfiles = true },
      update_focused_file = { enable = true },
      actions = {
        open_file = { resize_window = true },
      },
    },
  },
}
