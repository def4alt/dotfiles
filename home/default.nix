{
  lib,
  pkgs,
  username,
  stateVersion,
  platform,
  ...
}:
let
  isDarwin = lib.hasSuffix "darwin" platform;
  isLinux = lib.hasSuffix "linux" platform;
in
{
  home = {
    inherit stateVersion username;
    homeDirectory =
      if isDarwin then
        "/Users/${username}"
      else if isLinux then
        "/home/${username}"
      else
        "/";

    packages = with pkgs; [
      coreutils
      ncdu
      fd
      qpdf
      lazygit
      python3
      nodejs-slim
      pnpm
      pi-coding-agent
      gh
      age
      sops
      sshpass
      devenv
      yt-dlp
      qemu
      ffmpeg
      cheat
    ];

    sessionPath = [
      "$HOME/.local/bin"
      "$HOME/.cargo/bin"
    ]
    ++ lib.optionals isDarwin [
      "/opt/homebrew/bin"
      "/opt/homebrew/sbin"
    ];

    sessionVariables = {
      EDITOR = "nvim";
      LANG = "en_US.UTF-8";
      LC_COLLATE = "C";
      SYSTEMD_EDITOR = "nvim";
      VISUAL = "nvim";
      PNPM_HOME = "$HOME/.local/share/pnpm";
      PNPM_CONFIG_GLOBAL_DIR = "$HOME/.local/share/pnpm/global";
    };
  };

  home.shellAliases = {
    ll = "ls -lah";
    cat = "bat";
    update = if isDarwin then ''sudo darwin-rebuild switch --flake "$HOME/dotfiles#alderbook"'' else "";
  };

  fonts.fontconfig.enable = true;

  programs.home-manager.enable = true;

  home.file = {
    ".bashrc".force = true;
    ".profile".force = true;
  };

  programs.git = {
    enable = true;
    signing = lib.mkIf isDarwin {
      key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF5WXSF7FL2yTpqQjsZlSkIkvs7KqYxovtj3qWP72ayH";
      signByDefault = true;
    };
    settings = {
      user = {
        name = "Andrii Olkhovych";
        email = "andrii.olkhovych@tum.de";
      };
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
      gpg = lib.mkIf isDarwin {
        format = "ssh";
        ssh.program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
      };
      core.untrackedcache = true;
      fetch.prune = true;
      grep.lineNumber = true;
      help.autocorrect = 1;
      pull.rebase = true;
      merge.conflictStyle = "zdiff3";
    };
    ignores = [
      "[._]*.s[a-v][a-z]"
      "[._]*.sw[a-p]"
      "[._]s[a-v][a-z]"
      "[._]sw[a-p]"
      ".DS_Store"
      "**/.DS_Store"
      ".env*"
      "**/.env*"
      ".direnv"
    ];
  };

  imports = [
    ./modules/sops.nix
    ./modules/bash.nix
    ./modules/bat.nix
    ./modules/nvim.nix
    ./modules/fzf.nix
    ./modules/delta.nix
    ./modules/ripgrep.nix
    ./modules/zoxide.nix
    ./modules/direnv.nix
    ./modules/tmux.nix
    ./modules/ssh.nix
    ./modules/ghostty.nix
  ];
}
