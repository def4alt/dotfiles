-- Lazy.nvim configuration with LazyVim
-- This file is symlinked from the dotfiles repo, so changes take effect immediately.

require("lazy").setup({
  defaults = {
    lazy = true,
    version = false, -- always use the latest git commit
  },
  spec = {
    -- add LazyVim and import its plugins
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },

    -- disable mason.nvim, use programs.neovim.extraPackages from nix
    { "mason-org/mason-lspconfig.nvim", enabled = false },
    { "mason-org/mason.nvim", enabled = false },

    -- import/override with your plugins
    { import = "plugins" },
  },
  install = { colorscheme = { "tokyonight-night" } },
  checker = { enabled = false },
})
