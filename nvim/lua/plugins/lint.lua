return {
  {
    'mfussenegger/nvim-lint',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      local lint = require 'lint'
      lint.linters_by_ft = {
        markdown = { 'markdownlint' },
        vue = { 'eslint_d' },
        python = { 'flake8' },
        javascript = { 'eslint_d' },
      }

      vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
        group = vim.api.nvim_create_augroup('lint', { clear = true }),
        callback = function(args)
          -- Skip non-file buffers (e.g. diffview:// revisions)
          if vim.bo[args.buf].buftype ~= '' or vim.api.nvim_buf_get_name(args.buf):match '^%a+://' then
            return
          end
          local names = vim.tbl_filter(function(name)
            local linter = lint.linters[name]
            local cmd = type(linter) == 'table' and linter.cmd or name
            if type(cmd) == 'function' then
              cmd = cmd()
            end
            return vim.fn.executable(cmd) == 1
          end, lint._resolve_linter_by_ft(vim.bo[args.buf].filetype))
          if #names > 0 then
            lint.try_lint(names)
          end
        end,
      })
    end,
  },
}
