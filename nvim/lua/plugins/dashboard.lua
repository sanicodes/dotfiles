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

      local function get_git_stats()
        local stats = { added = 0, modified = 0, ahead = 0 }
        local h = io.popen 'git diff --shortstat 2>/dev/null'
        if h then
          local out = h:read '*a'
          h:close()
          stats.modified = tonumber(out:match '(%d+) file') or 0
        end
        h = io.popen 'git status --porcelain 2>/dev/null | grep "^?" | wc -l'
        if h then
          stats.added = tonumber(h:read('*a'):match '%d+') or 0
          h:close()
        end
        h = io.popen 'git rev-list --count @{u}..HEAD 2>/dev/null'
        if h then
          stats.ahead = tonumber(h:read('*a'):match '%d+') or 0
          h:close()
        end
        return stats
      end

      local function get_recent_sessions()
        local oldfiles = vim.v.oldfiles or {}
        local dirs = {}
        local seen = {}
        for _, f in ipairs(oldfiles) do
          local dir = vim.fn.fnamemodify(f, ':h')
          if not seen[dir] and vim.fn.isdirectory(dir) == 1 then
            seen[dir] = true
            table.insert(dirs, dir)
            if #dirs >= 3 then
              break
            end
          end
        end
        return dirs
      end

      require('dashboard').setup {
        theme = 'doom',
        config = {
          week_header = { enable = true },
          vertical_center = true,
          center = {
            { icon = ' ', desc = ' Find File               ', action = 'Telescope find_files', key = 'f' },
            { icon = ' ', desc = ' Recent Files            ', action = 'Telescope oldfiles', key = 'r' },
            { icon = ' ', desc = ' Live Grep               ', action = 'Telescope live_grep', key = 'g' },
            { icon = ' ', desc = ' File Browser            ', action = 'NvimTreeToggle', key = 'e' },
            { icon = ' ', desc = ' Git Status              ', action = 'Telescope git_status', key = 's' },
            { icon = ' ', desc = ' Git Commits             ', action = 'Telescope git_commits', key = 'o' },
            { icon = ' ', desc = ' Marks                   ', action = 'Telescope marks', key = 'k' },
            { icon = ' ', desc = ' Diagnostics             ', action = 'Telescope diagnostics', key = 'd' },
            { icon = ' ', desc = ' Configuration           ', action = 'lua require("telescope.builtin").find_files({ cwd = vim.fn.stdpath("config") })', key = 'c' },
            { icon = ' ', desc = ' Lazy                    ', action = 'Lazy', key = 'l' },
            { icon = ' ', desc = ' Mason                   ', action = 'Mason', key = 'm' },
            { icon = ' ', desc = ' New File                ', action = 'enew', key = 'n' },
            { icon = ' ', desc = ' Quit                    ', action = 'quit', key = 'q' },
          },
          footer = function()
            local stats = require('lazy').stats()
            local ms = math.floor(stats.startuptime * 100 + 0.5) / 100
            local branch = get_git_branch()
            local git = get_git_stats()
            local version = vim.version()
            local nvim_version = string.format('%d.%d.%d', version.major, version.minor, version.patch)

            local lines = { '' }

            -- Git info
            if branch then
              local display = #branch > 30 and (branch:sub(1, 30) .. '...') or branch
              local git_line = '  ' .. display
              local git_details = {}
              if git.modified > 0 then
                table.insert(git_details, '~' .. git.modified)
              end
              if git.added > 0 then
                table.insert(git_details, '+' .. git.added)
              end
              if git.ahead > 0 then
                table.insert(git_details, '' .. git.ahead)
              end
              if #git_details > 0 then
                git_line = git_line .. '  ' .. table.concat(git_details, '  ')
              end
              table.insert(lines, git_line)
            end

            -- Recent project directories
            local sessions = get_recent_sessions()
            if #sessions > 0 then
              table.insert(lines, '')
              table.insert(lines, ' Recent directories:')
              for _, dir in ipairs(sessions) do
                local short = dir:gsub(vim.env.HOME, '~')
                table.insert(lines, '    ' .. short)
              end
            end

            table.insert(lines, '')
            table.insert(lines, '󱐋 ' .. stats.loaded .. '/' .. stats.count .. ' plugins in ' .. ms .. 'ms')
            table.insert(lines, '󱓞  Neovim v' .. nvim_version .. '  |  ' .. os.date '%A, %B %d')
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
