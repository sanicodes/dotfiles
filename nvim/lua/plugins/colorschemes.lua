return {
  { -- You can easily change to a different colorscheme.
    -- Change the name of the colorscheme plugin below, and then
    -- change the command in the config to whatever the name of that colorscheme is.
    --
    -- If you want to see what colorschemes are already installed, you can use `:Telescope colorscheme`.
    'folke/tokyonight.nvim',
    priority = 1000, -- Make sure to load this before all the other start plugins.
    init = function()
      -- Load the colorscheme here.
      -- Like many other themes, this one has different styles, and you could load
      -- any other, such as 'tokyonight-storm', 'tokyonight-moon', or 'tokyonight-day'.
      -- You can configure highlights by doing something like:
      vim.cmd.hi 'Comment gui=none'
    end,
  },
  {
    'rebelot/kanagawa.nvim',
    priority = 1000,
    -- init = function()
    --   vim.cmd.colorscheme 'kanagawa-dragon' -- load the colorscheme on load
    -- end,
  },
  {
    'navarasu/onedark.nvim',
    priority = 1000, -- make sure to load this before all the other start plugins
    config = function()
      require('onedark').setup {
        style = 'warmer',
      }
      -- Enable theme
      -- require('onedark').load()
    end,
  },
  {
    'sainnhe/gruvbox-material',
    priority = 1000,
    config = function()
      -- vim.o.background = 'light' -- or 'light' for light mode
      vim.g.gruvbox_material_background = 'medium'
      vim.g.gruvbox_material_foreground = 'original'
      vim.g.gruvbox_material_enable_italic = 1
      vim.g.gruvbox_material_enable_bold = 1
      vim.g.gruvbox_material_cursor = 'auto'
      vim.g.gruvbox_material_dim_inactive_windows = 1
      vim.cmd.colorscheme 'gruvbox-material'
    end,
  },
}
