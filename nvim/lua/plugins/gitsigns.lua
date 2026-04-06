return {
  {
    'lewis6991/gitsigns.nvim',
    opts = function()
      local function on_attach(bufnr)
        local gs = require 'gitsigns'
        local function map(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
        end

        map('n', ']c', function()
          if vim.wo.diff then
            vim.cmd.normal { ']c', bang = true }
          else
            gs.nav_hunk 'next'
          end
        end, 'Git: Next hunk')

        map('n', '[c', function()
          if vim.wo.diff then
            vim.cmd.normal { '[c', bang = true }
          else
            gs.nav_hunk 'prev'
          end
        end, 'Git: Prev hunk')

        map('n', '<leader>hs', gs.stage_hunk, 'Git: Stage hunk')
        map('n', '<leader>hr', gs.reset_hunk, 'Git: Reset hunk')
        map('n', '<leader>hS', gs.stage_buffer, 'Git: Stage buffer')
        map('n', '<leader>hR', gs.reset_buffer, 'Git: Reset buffer')
        map('n', '<leader>hp', gs.preview_hunk, 'Git: Preview hunk')
        map('n', '<leader>hb', function()
          gs.blame_line { full = true }
        end, 'Git: Blame line')
        map('n', '<leader>hd', gs.diffthis, 'Git: Diff this')
        map('n', '<leader>tb', gs.toggle_current_line_blame, 'Toggle git blame')
        map({ 'o', 'x' }, 'ih', gs.select_hunk, 'Git: Inner hunk')
      end

      return {
        signs = {
          add = { text = '┃' },
          change = { text = '┃' },
          delete = { text = '_' },
          topdelete = { text = '‾' },
          changedelete = { text = '~' },
          untracked = { text = '┆' },
        },
        current_line_blame = true,
        current_line_blame_opts = {
          delay = 250,
          virt_text_pos = 'right_align',
        },
        current_line_blame_formatter = '<author>, <author_time:%R> - <summary>',
        preview_config = { border = 'rounded' },
        on_attach = on_attach,
      }
    end,
  },
}
