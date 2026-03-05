{
  pkgs,
  username,
  stateVersion,
  ...
}: let
  inherit (pkgs.stdenv) isDarwin isLinux;
in {
  home = {
    inherit stateVersion;
    inherit username;
    homeDirectory =
      if isDarwin
      then "/Users/${username}"
      else if isLinux
      then "/home/${username}"
      else "/";

    packages = with pkgs; [
      coreutils
      ripgrep
      wget
      lua
      luarocks
      ncdu
      # A simple, fast and user-friendly alternative to find
      fd
      # A smarter cd
      zoxide
      qpdf

      docker

      python3

      gh
      pay-respects
    ];

    sessionPath = [ "$HOME/.npm-global/bin" ];

    sessionVariables = {
      EDITOR = "nvim";
      SYSTEMD_EDITOR = "nvim";
      VISUAL = "nvim";
    };
  };

  manual.manpages.enable = true;
  programs.man.enable = true;
  programs.home-manager.enable = true;

  fonts.fontconfig.enable = true;

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
      theme = "robbyrussell";
    };

    shellAliases = {
      ll = "ls -l";
      update = "sudo darwin-rebuild switch --flake \"$HOME/dotfiles#alderbook\"";
      k = "kubectl";
    };

    initContent = ''
      # Remove alias from grep
      unalias grep 2>/dev/null
    '';

    history.size = 10000;
  };


  imports = [
    ./modules/bat.nix
    ./modules/nvim.nix
    ./modules/eza.nix
    ./modules/fzf.nix
    ./modules/git.nix
    ./modules/delta.nix
    ./modules/ripgrep.nix
    ./modules/zoxide.nix
    ./modules/ssh.nix
    ./modules/ghostty.nix
    ./modules/direnv.nix
  ];
}
