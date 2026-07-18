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

      nixd
      nixfmt

      bash-language-server
      shellcheck
      shfmt

      marksman
      yaml-language-server
      yamlfmt
    ];
  };

  # Keep the config writable so plugin updates can update nvim-pack-lock.json.
  xdg.configFile."nvim" = {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/home/modules/nvim";
    force = true;
  };
}
