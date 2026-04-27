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

  home.shellAliases.update = ''
    sudo darwin-rebuild switch --flake "$HOME/dotfiles#alderbook"
  '';

  manual.manpages.enable = true;
  programs.man.enable = true;
  programs.home-manager.enable = true;

  fonts.fontconfig.enable = true;

  programs.zsh = {
    enable = true;
    enableCompletion = false;

    initContent = lib.mkForce ''
      HISTSIZE="10000"
      SAVEHIST="10000"

      HISTFILE="$HOME/.zsh_history"
      mkdir -p "$(dirname "$HISTFILE")"

      set_opts=(
        HIST_FCNTL_LOCK HIST_IGNORE_DUPS HIST_IGNORE_SPACE SHARE_HISTORY
        NO_APPEND_HISTORY NO_EXTENDED_HISTORY NO_HIST_EXPIRE_DUPS_FIRST
        NO_HIST_FIND_NO_DUPS NO_HIST_IGNORE_ALL_DUPS NO_HIST_SAVE_NO_DUPS
      )
      for opt in "''${set_opts[@]}"; do
        setopt "$opt"
      done
      unset opt set_opts

      if [ -f "$HOME/.p10k.zsh" ]; then
        source "$HOME/.p10k.zsh"
      fi

      source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
    '';
  };

  home.file.".p10k.zsh" = {
    text = ''
      source ${pkgs.zsh-powerlevel10k}/share/zsh/themes/powerlevel10k/config/p10k-lean.zsh
      typeset -g POWERLEVEL9K_VCS_GIT_GITHUB_ICON=""
      typeset -g POWERLEVEL9K_DIR_VISUAL_IDENTIFIER_EXPANSION=""
      typeset -g POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true
      typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet
    '';
  };

  imports = [
    ./modules/sops.nix
    ./modules/bat.nix
    ./modules/nvim.nix
    ./modules/fzf.nix
    ./modules/git.nix
    ./modules/delta.nix
    ./modules/ripgrep.nix
    ./modules/zoxide.nix
    ./modules/direnv.nix
    ./modules/ghostty.nix
    ./modules/tmux.nix
  ];
}
