return {
  {
    'nvimdev/dashboard-nvim',
    event = 'VimEnter',
    config = function()
      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'dashboard',
        callback = function()
          vim.opt_local.fillchars = { vert = ' ' }
          vim.opt_local.statuscolumn = ''
        end,
      })

      require('dashboard').setup {

        theme = 'doom',
        config = {
          week_header = {
            enable = true,
          },
          vertical_center = true,
          center = {
            {
              icon = ' ',
              desc = ' Find File                        [space][s][f]',
              action = 'lua require("telescope.builtin").find_files()',
            },
            {
              icon = ' ',
              desc = ' Recent Files                     [space][s][.]',
              action = 'lua require("telescope.builtin").oldfiles()',
            },
            {
              icon = ' ',
              desc = ' Live Grep                        [space][s][g]',
              action = 'lua require("telescope.builtin").live_grep()',
            },
            {
              icon = ' ',
              desc = ' File Browser                     [\\]',
              action = 'Neotree toggle',
            },
            {
              icon = ' ',
              desc = ' Configuration                    [space][s][n]',
              action = 'lua require("telescope.builtin").find_files({ cwd = vim.fn.stdpath("config") })',
            },
            {
              icon = ' ',
              desc = ' Help Tags                        [space][s][h]',
              action = 'lua require("telescope.builtin").help_tags()',
            },
            {
              icon = '󰒲 ',
              desc = ' Lazy Package Manager             :Lazy',
              action = 'Lazy',
            },
            {
              icon = ' ',
              desc = ' Mason LSP Manager                :Mason',
              action = 'Mason',
            },
            {
              icon = ' ',
              desc = ' Quit Neovim                      :q',
              action = 'quit',
            },
          },
          footer = function()
            local stats = require('lazy').stats()
            local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
            return {
              '',
              '⚡ Neovim loaded ' .. stats.loaded .. '/' .. stats.count .. ' plugins in ' .. ms .. 'ms',
              '',
            }
          end,
        },
      }

      vim.api.nvim_set_hl(0, 'DashboardHeader', { fg = '#ffffff', bold = true })
      vim.api.nvim_set_hl(0, 'DashboardFooter', { fg = '#ffffff', bold = true })
      vim.api.nvim_set_hl(0, 'DashboardDesc', { fg = '#ffffff', bold = true })
    end,
    dependencies = { { 'nvim-tree/nvim-web-devicons' } },
  },
}
