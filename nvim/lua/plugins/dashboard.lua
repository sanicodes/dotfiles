return {
  {
    'nvimdev/dashboard-nvim',
    event = 'VimEnter',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'dashboard',
        callback = function()
          vim.opt_local.fillchars = { vert = ' ' }
          vim.opt_local.statuscolumn = ''
        end,
      })

      local function get_git_branch()
        local handle = io.popen 'git branch --show-current 2>/dev/null'
        if handle then
          local branch = handle:read('*a'):gsub('\n', '')
          handle:close()
          return branch ~= '' and branch or nil
        end
        return nil
      end

      require('dashboard').setup {
        theme = 'doom',
        config = {
          week_header = { enable = true },
          vertical_center = true,
          center = {
            { icon = ' ', desc = ' Find File            ', action = 'Telescope find_files', key = 'f' },
            { icon = ' ', desc = ' Recent Files         ', action = 'Telescope oldfiles', key = 'r' },
            { icon = ' ', desc = ' Live Grep            ', action = 'Telescope live_grep', key = 'g' },
            { icon = ' ', desc = ' File Browser         ', action = 'NvimTreeToggle', key = 'e' },
            { icon = ' ', desc = ' Configuration        ', action = 'lua require("telescope.builtin").find_files({ cwd = vim.fn.stdpath("config") })', key = 'c' },
            { icon = ' ', desc = ' Quit                 ', action = 'quit', key = 'q' },
          },
          footer = function()
            local stats = require('lazy').stats()
            local ms = math.floor(stats.startuptime * 100 + 0.5) / 100
            local branch = get_git_branch()
            local version = vim.version()
            local nvim_version = string.format('%d.%d.%d', version.major, version.minor, version.patch)

            local lines = { '' }
            if branch then
              local display = #branch > 40 and (branch:sub(1, 40) .. '...') or branch
              table.insert(lines, '  ' .. display)
            end
            table.insert(lines, '󱐋 ' .. stats.loaded .. '/' .. stats.count .. ' plugins in ' .. ms .. 'ms')
            table.insert(lines, '󱓞  Neovim v' .. nvim_version)
            return lines
          end,
        },
      }

      local is_dark = (vim.o.background == 'dark')
      if is_dark then
        vim.api.nvim_set_hl(0, 'DashboardHeader', { fg = '#f7f5f5', bold = true })
        vim.api.nvim_set_hl(0, 'DashboardFooter', { fg = '#e8e8e8', italic = true })
        vim.api.nvim_set_hl(0, 'DashboardDesc', { fg = '#f0f0f0' })
        vim.api.nvim_set_hl(0, 'DashboardIcon', { fg = '#d3d3d3' })
        vim.api.nvim_set_hl(0, 'DashboardKey', { fg = '#f8f8f2', bold = true })
      else
        vim.api.nvim_set_hl(0, 'DashboardHeader', { fg = '#1c1c1c', bold = true })
        vim.api.nvim_set_hl(0, 'DashboardFooter', { fg = '#444444', italic = true })
        vim.api.nvim_set_hl(0, 'DashboardDesc', { fg = '#333333' })
        vim.api.nvim_set_hl(0, 'DashboardIcon', { fg = '#4a4a4a' })
        vim.api.nvim_set_hl(0, 'DashboardKey', { fg = '#000000', bold = true })
      end
    end,
  },
}
