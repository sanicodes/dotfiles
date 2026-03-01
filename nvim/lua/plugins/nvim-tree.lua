return {
  {
    'nvim-tree/nvim-tree.lua',
    cmd = {
      'NvimTreeToggle',
      'NvimTreeFocus',
      'NvimTreeFindFile',
      'NvimTreeFindFileToggle',
    },
    keys = {
      { '\\', '<cmd>NvimTreeToggle<CR>', desc = 'File Explorer', silent = true },
      { '<leader>e', '<cmd>NvimTreeFindFileToggle<CR>', desc = 'Explorer (Current File)', silent = true },
    },
    dependencies = {
      'nvim-tree/nvim-web-devicons',
    },
    config = function()
      require('nvim-tree').setup {
        disable_netrw = true,
        hijack_netrw = true,
        sync_root_with_cwd = false,

        sort = {
          sorter = 'case_sensitive',
        },

        view = {
          width = 35,
          preserve_window_proportions = true,
        },

        renderer = {
          root_folder_label = false,
          indent_markers = {
            enable = true,
          },
          icons = {
            show = {
              file = true,
              folder = true,
              folder_arrow = true,
              git = true,
              modified = true,
            },
            glyphs = {
              default = '󰈚',
              symlink = '',
              bookmark = '󰆤',
              folder = {
                arrow_closed = '',
                arrow_open = '',
                default = '',
                open = '',
                empty = '',
                empty_open = '',
                symlink = '',
                symlink_open = '',
              },
              git = {
                unstaged = 'x',
                staged = '✓',
                unmerged = '',
                renamed = '➜',
                untracked = '★',
                deleted = '',
                ignored = '◌',
              },
            },
          },
        },

        git = {
          enable = true,
          ignore = true,
        },

        filters = {
          dotfiles = true,
          git_ignored = true,
        },

        update_focused_file = {
          enable = true,
          update_root = {
            enable = false,
          },
        },

        actions = {
          open_file = {
            quit_on_open = false,
            resize_window = true,
          },
        },
      }
    end,
  },
}
