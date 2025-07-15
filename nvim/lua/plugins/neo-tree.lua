-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

return {
  {
    'nvim-neo-tree/neo-tree.nvim',
    version = '*',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
      'MunifTanjim/nui.nvim',
    },
    cmd = 'Neotree',
    keys = {
      { '\\', ':Neotree reveal<CR>', desc = 'NeoTree reveal', silent = true },
    },
    opts = {
      filesystem = {
        window = {
          mappings = {
            ['\\'] = 'close_window',
            ['P'] = {
              'toggle_preview',
              config = {
                use_float = true,
                -- use_image_nvim = true,
                -- use_snacks_image = true,
                -- title = 'Neo-tree Preview',
              },
            },
          },
        },
        follow_current_file = {
          enabled = true,
          leave_dirs_open = true,
        },
      },
    },
  },
}
