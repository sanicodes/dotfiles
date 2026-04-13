--[[
--
-- This file is not required for your own configuration,
-- but helps people determine if their system is setup correctly.
--
--]]

local check_version = function()
  local verstr = tostring(vim.version())
  if not vim.version.ge then
    vim.health.error(string.format("Neovim out of date: '%s'. Upgrade to latest stable or nightly", verstr))
    return
  end

  if vim.version.ge(vim.version(), '0.12.0') then
    vim.health.ok(string.format("Neovim version is: '%s'", verstr))
  else
    vim.health.error(string.format("Neovim out of date: '%s'. Upgrade to latest stable or nightly", verstr))
  end
end

local tree_sitter_cli_version = function()
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

local has_required_tree_sitter_cli = function()
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

local check_treesitter_cli = function()
  local version = tree_sitter_cli_version()
  local ok = has_required_tree_sitter_cli()

  if ok and version then
    vim.health.ok(string.format("Found executable: 'tree-sitter' (%s)", version.raw))
    return
  end

  if version and version.raw then
    vim.health.warn(
      string.format("Found executable: 'tree-sitter' (%s), but nvim-treesitter on Neovim 0.12 requires 0.26.1+", version.raw),
      {
        'Upgrade tree-sitter-cli to 0.26.1 or newer.',
        'Version matters: older releases like Ubuntu 24.04 package 0.20.8 are too old.',
        'Install the latest version with `npm install -g tree-sitter-cli@latest` if your distro package is outdated.',
      }
    )
    return
  end

  vim.health.warn("Could not find executable: 'tree-sitter'", {
    'Install tree-sitter-cli 0.26.1 or newer.',
    'Install the latest version with `npm install -g tree-sitter-cli@latest`.',
  })
end

local check_external_reqs = function()
  -- Basic utils: `git`, `make`, `unzip`
  for _, exe in ipairs { 'git', 'make', 'unzip', 'rg' } do
    local is_executable = vim.fn.executable(exe) == 1
    if is_executable then
      vim.health.ok(string.format("Found executable: '%s'", exe))
    else
      vim.health.warn(string.format("Could not find executable: '%s'", exe))
    end
  end

  return true
end

return {
  check = function()
    vim.health.start 'Checking Your Neovim'

    vim.health.info [[NOTE: Not every warning is a 'must-fix' in `:checkhealth`

    Fix only warnings for plugins and languages you intend to use.
    Mason will give warnings for languages that are not installed.
    You do not need to install, unless you want to use those languages!]]

    local uv = vim.uv or vim.loop
    vim.health.info('System Information: ' .. vim.inspect(uv.os_uname()))

    check_version()
    check_external_reqs()
    check_treesitter_cli()
  end,
}
