return {
  {
    'lewis6991/gitsigns.nvim',
    opts = function()
      local function on_attach(bufnr)
        local gitsigns = require 'gitsigns'

        local function map(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
        end

        map('n', ']c', function()
          if vim.wo.diff then
            vim.cmd.normal { ']c', bang = true }
          else
            gitsigns.nav_hunk 'next'
          end
        end, 'Git: Next hunk')

        map('n', '[c', function()
          if vim.wo.diff then
            vim.cmd.normal { '[c', bang = true }
          else
            gitsigns.nav_hunk 'prev'
          end
        end, 'Git: Prev hunk')

        map('n', '<leader>hs', gitsigns.stage_hunk, 'Git [H]unk [S]tage')
        map('n', '<leader>hr', gitsigns.reset_hunk, 'Git [H]unk [R]eset')

        map('v', '<leader>hs', function()
          gitsigns.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, 'Git [H]unk [S]tage')

        map('v', '<leader>hr', function()
          gitsigns.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, 'Git [H]unk [R]eset')

        map('n', '<leader>hS', gitsigns.stage_buffer, 'Git [H]unk [S]tage buffer')
        map('n', '<leader>hu', gitsigns.stage_hunk, 'Git [H]unk stage/[U]nstage')
        map('n', '<leader>hR', gitsigns.reset_buffer, 'Git [H]unk [R]eset buffer')
        map('n', '<leader>hU', gitsigns.reset_buffer_index, 'Git [H]unk [U]nstage buffer')
        map('n', '<leader>hp', gitsigns.preview_hunk, 'Git [H]unk [P]review')
        map('n', '<leader>hi', gitsigns.preview_hunk_inline, 'Git [H]unk preview [I]nline')

        map('n', '<leader>hb', function()
          gitsigns.blame_line { full = true }
        end, 'Git [H]unk [B]lame line')

        map('n', '<leader>hd', gitsigns.diffthis, 'Git [H]unk [D]iff this')
        map('n', '<leader>hD', function()
          gitsigns.diffthis '~'
        end, 'Git [H]unk [D]iff against ~')

        map('n', '<leader>hq', gitsigns.setqflist, 'Git [H]unk [Q]uickfix')
        map('n', '<leader>hQ', function()
          gitsigns.setqflist 'all'
        end, 'Git [H]unk [Q]uickfix all')

        map('n', '<leader>tb', gitsigns.toggle_current_line_blame, '[T]oggle git [B]lame')
        map('n', '<leader>tw', gitsigns.toggle_word_diff, '[T]oggle git [W]ord diff')
        map('n', '<leader>td', gitsigns.toggle_linehl, '[T]oggle git line [D]iff')

        map({ 'o', 'x' }, 'ih', gitsigns.select_hunk, 'Git [I]nner [H]unk')
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
        signs_staged = {
          add = { text = '┃' },
          change = { text = '┃' },
          delete = { text = '_' },
          topdelete = { text = '‾' },
          changedelete = { text = '~' },
          untracked = { text = '┆' },
        },
        signs_staged_enable = true,
        signcolumn = true,
        watch_gitdir = {
          follow_files = true,
        },
        attach_to_untracked = true,
        current_line_blame = true,
        current_line_blame_opts = {
          delay = 250,
          ignore_whitespace = false,
          virt_text_pos = 'right_align',
        },
        current_line_blame_formatter = '<author>, <author_time:%R> - <summary>',
        update_debounce = 100,
        preview_config = {
          border = 'rounded',
        },
        on_attach = on_attach,
      }
    end,
  },
}
