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
      direnv
      coreutils
      ripgrep
      gnused
      wget
      pre-commit
      gnupg
      sops
      nodejs
      luarocks
      ncdu
      # A simple, fast and user-friendly alternative to find
      fd
      # A smarter cd
      zoxide

      docker

      uv
      gh

      # SkiGaudi
      firebase-tools
      google-cloud-sdk
      claude-code
    ];

    sessionVariables = {
      EDITOR = "nvim";
      MANPAGER = "sh -c 'col --no-backspaces --spaces | bat --language man'";
      MANROFFOPT = "-c";
      PAGER = "bat";
      SYSTEMD_EDITOR = "nvim";
      VISUAL = "nvim";
    };
  };

  manual.manpages.enable = true;
  programs.man.enable = true;
  programs.home-manager.enable = true;

  fonts.fontconfig.enable = true;

  imports = [
    ./modules/bat.nix
    ./modules/nvim.nix
    ./modules/eza.nix
    ./modules/fzf.nix
    ./modules/git.nix
    ./modules/ripgrep.nix
    ./modules/tmux.nix
    ./modules/zoxide.nix
    ./modules/ssh.nix
    ./modules/ghostty.nix
  ];
}
