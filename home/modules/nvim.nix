{
  config,
  pkgs,
  ...
}:
{
  programs.neovim = {
    enable = true;
    withRuby = true;
    withPython3 = true;

    # Tools and LSP servers available on $PATH for Neovim.
    extraPackages = with pkgs; [
      # general dependencies
      git
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

    plugins = [ ];

    initLua = ''
      vim.g.mapleader = " "
      vim.g.maplocalleader = " "

      vim.pack.add({
        { src = "https://github.com/rebelot/kanagawa.nvim" },
        { src = "https://github.com/nvim-treesitter/nvim-treesitter" },
        { src = "https://github.com/nvim-lualine/lualine.nvim" },
        { src = "https://github.com/echasnovski/mini.completion" },
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

  # mkOutOfStoreSymlink so files remain writable — edit and see changes immediately without rebuilding.
  xdg.configFile."nvim/plugin" = {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/home/modules/nvim/plugin";
    recursive = true;
    force = true;
  };
}
