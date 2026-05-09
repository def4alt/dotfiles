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
    ];

    # lazy-nvim is installed here so it's available to bootstrap.
    # All other plugins are managed by lazy.nvim itself.
    plugins = with pkgs.vimPlugins; [ lazy-nvim ];

    # Load the lazy config from the symlinked lua directory.
    # See lua/config/lazy.lua for the full lazy setup.
    extraLuaConfig = ''
      require("config.lazy")
    '';
  };

  # Normal LazyVim config here, like this: https://github.com/LazyVim/starter/tree/main/lua
  # mkOutOfStoreSymlink is used instead of a regular source so the files
  # aren't copied into the Nix store. This keeps them writable, allowing
  # you to edit your Lua config and see changes immediately without rebuilding.
  xdg.configFile."nvim/lazyvim.json" = {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/home/modules/nvim/lazyvim.json";
    force = true;
  };

  xdg.configFile."nvim/lua" = {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/home/modules/nvim/lua";
    recursive = true;
    force = true;
  };
}
