vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- compiles mjml files. Requires MJML to be manually installed.
vim.api.nvim_create_user_command('MjmlCompile', function()
  local current_file = vim.fn.expand '%:p'
  if current_file:match '%.mjml$' then
    local output_file = current_file:gsub('%.mjml$', '.html')
    vim.cmd('!mjml ' .. current_file .. ' -o ' .. output_file)
    print('Compiled ' .. current_file .. ' to ' .. output_file)
  else
    print 'Not an MJML file.'
  end
end, { desc = 'Compile current MJML file to HTML' })

-- treats mjml files like html files since TS does not support it yet
vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
  pattern = '*.mjml',
  callback = function()
    vim.bo.filetype = 'html'
  end,
})
