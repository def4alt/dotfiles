{
  config,
  pkgs,
  ...
}:
{
  programs.neovim = {
    enable = true;
    withRuby = false;
    withPython3 = false;

    extraPackages = with pkgs; [
      git
      ripgrep
      fzf
      fd
      tree-sitter

      lua-language-server
      stylua

      nil
      nixfmt
      statix

      bash-language-server
      marksman
      vscode-langservers-extracted
      yaml-language-server

      pyright
      ruff

      go
      gopls
      golangci-lint

      cargo
      rustc
      clippy
      rustfmt
      rust-analyzer

      oxlint
      oxfmt
      vtsls
    ];

    initLua = ''
      vim.g.mapleader = " "
      vim.g.maplocalleader = " "

      vim.pack.add({
        { src = "https://github.com/rebelot/kanagawa.nvim" },
        { src = "https://github.com/nvim-treesitter/nvim-treesitter" },
        { src = "https://github.com/vieitesss/miniharp.nvim" },
        { src = "https://github.com/stevearc/oil.nvim" },
        { src = "https://github.com/echasnovski/mini.ai" },
        { src = "https://github.com/echasnovski/mini.surround" },
        { src = "https://github.com/echasnovski/mini.pairs" },
        { src = "https://github.com/echasnovski/mini.icons" },
        { src = "https://github.com/echasnovski/mini.diff" },
        { src = "https://github.com/echasnovski/mini.hipatterns" },
        { src = "https://github.com/echasnovski/mini.clue" },
        { src = "https://github.com/ibhagwan/fzf-lua" },
      }, { load = true })
    '';
  };

  # Keep plugin files writable so changes do not require a Home Manager rebuild.
  xdg.configFile."nvim/plugin" = {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/home/modules/nvim/plugin";
    recursive = true;
    force = true;
  };
}
