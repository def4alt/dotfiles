{
  lib,
  pkgs,
  inputs,
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
      tmux

      python3
      nodejs

      gh
      pay-respects

      age
      sops
    ];

    sessionPath = [ "$HOME/.npm-global/bin" ];

    sessionVariables = {
      EDITOR = "nvim";
      SYSTEMD_EDITOR = "nvim";
      VISUAL = "nvim";
      NPM_CONFIG_PREFIX = "$HOME/.npm-global";
      SOPS_AGE_KEY_FILE = "$HOME/.config/sops/age/keys.txt";
    };
  };

  home.activation.installPiCodingAgent = lib.hm.dag.entryAfter ["writeBoundary"] ''
    export PATH="$HOME/.npm-global/bin:${pkgs.nodejs}/bin:$PATH"
    mkdir -p "$HOME/.npm-global"

    if [ ! -x "$HOME/.npm-global/bin/pi" ]; then
      npm install --location=global --prefix "$HOME/.npm-global" @mariozechner/pi-coding-agent
    fi
  '';

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
    ./modules/sops.nix
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
    ./modules/tmux.nix
    ./modules/direnv.nix
  ];
}
