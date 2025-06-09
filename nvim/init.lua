--[[ ENTRY POINT FOR THE NEOVIM CONFIG ]]

require 'config.options'
require 'config.keymaps'
require 'config.autocmds'
require 'config.lazy'
require('health.system').check()
