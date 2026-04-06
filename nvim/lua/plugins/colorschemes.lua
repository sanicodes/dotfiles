return {
  { 'folke/tokyonight.nvim', priority = 1000 },
  { 'rebelot/kanagawa.nvim', priority = 1000 },
  { 'catppuccin/nvim', name = 'catppuccin', priority = 1000 },
  { 'EdenEast/nightfox.nvim' },
  { 'Mofiqul/vscode.nvim' },
  {
    'navarasu/onedark.nvim',
    priority = 1000,
    config = function()
      require('onedark').setup { style = 'warmer' }
      require('onedark').load()
    end,
  },
}
