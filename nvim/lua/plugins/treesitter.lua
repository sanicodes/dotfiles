local ensure_installed = {
  'bash',
  'c',
  'diff',
  'html',
  'lua',
  'luadoc',
  'markdown',
  'markdown_inline',
  'query',
  'vim',
  'vimdoc',
}

local function tree_sitter_cli_version()
  if vim.fn.executable 'tree-sitter' ~= 1 then
    return nil
  end

  local output = vim.fn.systemlist { 'tree-sitter', '--version' }
  local line = output[1] or ''
  local major, minor, patch = line:match '(%d+)%.(%d+)%.(%d+)'
  if not major then
    return nil
  end

  return {
    major = tonumber(major),
    minor = tonumber(minor),
    patch = tonumber(patch),
    raw = ('%s.%s.%s'):format(major, minor, patch),
  }
end

local function has_required_tree_sitter_cli()
  local version = tree_sitter_cli_version()
  if not version then
    return false, nil
  end
  if version.major > 0 then
    return true, version
  end
  if version.minor > 26 then
    return true, version
  end
  if version.minor == 26 and version.patch >= 1 then
    return true, version
  end
  return false, version
end

local function tree_sitter_cli_requirement_message()
  local ok, version = has_required_tree_sitter_cli()
  if ok then
    return nil
  end

  local message = 'nvim-treesitter on Neovim 0.12 requires `tree-sitter-cli` 0.26.1 or newer.'
  if version and version.raw then
    message = message .. (' Detected: %s.'):format(version.raw)
  else
    message = message .. ' `tree-sitter` is not installed.'
  end
  return message .. ' Install the latest version with `npm install -g tree-sitter-cli@latest`.'
end

return {
  {
    'nvim-treesitter/nvim-treesitter',
    lazy = false,
    branch = 'main',
    build = ':TSUpdate',
    config = function()
      local ts = require 'nvim-treesitter'

      ts.setup()
      local ok = has_required_tree_sitter_cli()
      if ok then
        ts.install(ensure_installed)
      else
        vim.schedule(function()
          vim.notify_once(tree_sitter_cli_requirement_message(), vim.log.levels.WARN)
        end)
      end

      vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup('dotfiles-treesitter-start', { clear = true }),
        callback = function(args)
          local ok = pcall(vim.treesitter.start, args.buf)
          if not ok then
            return
          end

          if vim.bo[args.buf].filetype ~= 'ruby' then
            vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })
    end,
  },
}
