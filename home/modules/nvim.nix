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
    sideloadInitLua = true;

    extraPackages = with pkgs; [
      git
      ripgrep
      tree-sitter

      lua-language-server
      stylua
      lua
      luarocks

      nil
      nixfmt

      bash-language-server
      marksman
      shellcheck
      shfmt
      vscode-langservers-extracted
      yaml-language-server
      yamlfmt

      pyright
      ruff

      go
      gofumpt
      gopls

      cargo
      rustc
      clippy
      rustfmt
      rust-analyzer

      zig
      zls

      oxlint
      oxfmt
      vtsls
    ];
  };

  # Keep the config writable so plugin updates can update nvim-pack-lock.json.
  xdg.configFile."nvim" = {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/home/modules/nvim";
    force = true;
  };
}
