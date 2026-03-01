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

      -- Helper functions for additional stats
      local function get_git_branch()
        local handle = io.popen 'git branch --show-current 2>/dev/null'
        if handle then
          local branch = handle:read('*a'):gsub('\n', '')
          handle:close()
          return branch ~= '' and branch or nil
        end
        return nil
      end

      local function get_git_status()
        local handle = io.popen 'git status --porcelain 2>/dev/null | wc -l'
        if handle then
          local count = handle:read('*a'):gsub('\n', '')
          handle:close()
          return tonumber(count) or 0
        end
        return 0
      end

      local function get_current_directory()
        return vim.fn.fnamemodify(vim.fn.getcwd(), ':t')
      end

      local function get_full_path()
        return vim.fn.getcwd()
      end

      local function get_neovim_version()
        local version = vim.version()
        return string.format('%d.%d.%d', version.major, version.minor, version.patch)
      end

      local function get_system_info()
        local os_name = vim.loop.os_uname().sysname
        return os_name
      end

      -- Function to left-align text lines within centered footer
      local function left_align_footer(lines)
        local aligned_lines = {}
        local max_width = 0

        -- First pass: find the maximum width (excluding empty lines and box characters)
        for _, line in ipairs(lines) do
          if line ~= '' and not line:match '^[╭├╰─│╮╯┤]+$' then
            -- Remove box characters for width calculation
            local content = line:gsub('[╭├╰─│╮╯┤]', ''):gsub('^ +', ''):gsub(' +$', '')
            local visible_length = vim.fn.strdisplaywidth(content)
            max_width = math.max(max_width, visible_length)
          end
        end

        -- Set a minimum width for the box
        local box_width = math.max(max_width + 8, 68) -- 4 chars padding on each side

        -- Second pass: create properly aligned box
        for i, line in ipairs(lines) do
          if line == '' then
            table.insert(aligned_lines, line)
          elseif line:match '^╭' then
            -- Top border
            table.insert(aligned_lines, '╭' .. string.rep('─', box_width - 2) .. '╮')
          elseif line:match '^├' then
            -- Middle border
            table.insert(aligned_lines, '├' .. string.rep('─', box_width - 2) .. '┤')
          elseif line:match '^╰' then
            -- Bottom border
            table.insert(aligned_lines, '╰' .. string.rep('─', box_width - 2) .. '╯')
          else
            -- Content line
            local content = line:gsub('^│ ?', ''):gsub(' ?│$', '')
            local visible_length = vim.fn.strdisplaywidth(content)
            local padding = box_width - 4 - visible_length -- 2 for borders, 2 for inner padding
            local aligned_line = '│ ' .. content .. string.rep(' ', math.max(0, padding)) .. ' │'
            table.insert(aligned_lines, aligned_line)
          end
        end

        return aligned_lines
      end

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
              action = 'NvimTreeToggle',
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
            local ms = math.floor(stats.startuptime * 100 + 0.5) / 100

            -- Gather system information
            local branch = get_git_branch()
            local git_changes = get_git_status()
            local current_dir = get_current_directory()
            local full_path = get_full_path()
            local nvim_version = get_neovim_version()
            local os_info = get_system_info()
            local display_branch = branch
            if branch and #branch > 40 then
              display_branch = branch:sub(1, 40) .. '...'
            end

            local footer_lines = {
              '',
              '╭─────────────────────────────────────────────────────────────────╮',
              -- Git status
              branch and ('│  ' .. display_branch .. (git_changes > 0 and ' (' .. git_changes .. ' changes)' or ' (clean)') .. ' │')
                or '│ 📝 Not a git repository │',
              '├─────────────────────────────────────────────────────────────────┤',
              '│   ' .. (full_path:len() > 55 and ('...' .. full_path:sub(-52)) or full_path) .. ' │',
              '├─────────────────────────────────────────────────────────────────┤',
              '│ 󱐋 Loaded ' .. stats.loaded .. '/' .. stats.count .. ' plugins in ' .. ms .. 'ms │',
              '├─────────────────────────────────────────────────────────────────┤',
              '│ 󱓞  Neovim v' .. nvim_version .. ' on ' .. os_info .. ' │',
              '╰─────────────────────────────────────────────────────────────────╯',
            }

            -- Left-align the footer text
            return left_align_footer(footer_lines)
          end,
        },
      }

      -- Detect current background (set earlier by your colorscheme logic)
      local is_dark = (vim.o.background == 'dark')

      if is_dark then
        -- Dark mode colors (lighter text on dark background)
        vim.api.nvim_set_hl(0, 'DashboardHeader', { fg = '#f7f5f5', bold = true }) -- Off-white header
        vim.api.nvim_set_hl(0, 'DashboardFooter', { fg = '#e8e8e8', italic = true }) -- Light gray footer
        vim.api.nvim_set_hl(0, 'DashboardDesc', { fg = '#f0f0f0' }) -- Soft white descriptions
        vim.api.nvim_set_hl(0, 'DashboardIcon', { fg = '#d3d3d3' }) -- Light gray icons
        vim.api.nvim_set_hl(0, 'DashboardKey', { fg = '#f8f8f2', bold = true }) -- Cream keybinds
      else
        -- Light mode colors (darker text on bright background)
        vim.api.nvim_set_hl(0, 'DashboardHeader', { fg = '#1c1c1c', bold = true })
        vim.api.nvim_set_hl(0, 'DashboardFooter', { fg = '#444444', italic = true })
        vim.api.nvim_set_hl(0, 'DashboardDesc', { fg = '#333333' })
        vim.api.nvim_set_hl(0, 'DashboardIcon', { fg = '#4a4a4a' })
        vim.api.nvim_set_hl(0, 'DashboardKey', { fg = '#000000', bold = true })
      end
    end,
    dependencies = { { 'nvim-tree/nvim-web-devicons' } },
  },
}
