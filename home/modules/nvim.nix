{config, pkgs, lib, ...}: {
  programs.neovim = {
    enable = true;
    withRuby = true;
    withPython3 = true;

    # Tools and LSP servers available on $PATH for Neovim.
    extraPackages = with pkgs; [
      # general dependencies
      git
      lazygit
      ripgrep
      fzf
      fd
      tree-sitter

      # LUA
      lua-language-server
      stylua

      # NIX
      nil
      nixfmt
      statix

      # LSP servers (configured via native vim.lsp.config)
      gopls
      rust-analyzer
      pyright
      typescript-language-server
      yaml-language-server
      bash-language-server
    ];

    plugins = [];

    initLua = ''
      vim.g.mapleader = " "
      vim.g.maplocalleader = " "

      -- Install and load plugins via native vim.pack (Neovim 0.12+)
      -- All plugins track their default branch (no version constraint)
      -- Use :Packupdate to update, :Packdel to remove
      vim.pack.add({
        { src = "https://github.com/rebelot/kanagawa.nvim" },
        { src = "https://github.com/nvim-treesitter/nvim-treesitter" },
        { src = "https://github.com/saghen/blink.cmp" },
        { src = "https://github.com/rafamadriz/friendly-snippets" },
        { src = "https://github.com/nvim-lualine/lualine.nvim" },
        { src = "https://github.com/vieitesss/miniharp.nvim" },
        { src = "https://github.com/stevearc/oil.nvim" },
        { src = "https://github.com/echasnovski/mini.ai" },
        { src = "https://github.com/echasnovski/mini.surround" },
        { src = "https://github.com/echasnovski/mini.pairs" },
        { src = "https://github.com/echasnovski/mini.icons" },
        { src = "https://github.com/echasnovski/mini.diff" },
        { src = "https://github.com/echasnovski/mini.hipatterns" },
        { src = "https://github.com/echasnovski/mini.pick" },
        { src = "https://github.com/echasnovski/mini.clue" },
      }, { load = true })

      -- Everything in plugin/ is auto-loaded by Neovim
    '';
  };

  # mkOutOfStoreSymlink so files remain writable — edit and see changes immediately without rebuilding.
  xdg.configFile."nvim/plugin" = {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/home/modules/nvim/plugin";
    recursive = true;
    force = true;
  };
}
