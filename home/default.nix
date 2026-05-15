{
  lib,
  pkgs,
  inputs,
  username,
  hostname,
  stateVersion,
  ...
}: let
  inherit (pkgs.stdenv) isDarwin isLinux;
in {
  home = {
    inherit stateVersion username;
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
      fd
      zoxide
      qpdf
      tmux
      python3
      nodejs
      gh
      pay-respects
      age
      sops
    ] ++ lib.optionals isLinux [
      docker
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

  # ── macOS-only pi coding agent activation ───
  home.activation.installPiCodingAgent =
    lib.mkIf isDarwin
    (lib.hm.dag.entryAfter ["writeBoundary"] ''
      export PATH="$HOME/.npm-global/bin:${pkgs.nodejs}/bin:$PATH"
      mkdir -p "$HOME/.npm-global"
      if [ ! -x "$HOME/.npm-global/bin/pi" ]; then
        npm install --location=global --prefix "$HOME/.npm-global" @mariozechner/pi-coding-agent
      fi
    '');

  # ── Shell alias: platform-aware rebuild ───
  home.shellAliases.update =
    if isDarwin
    then ''sudo darwin-rebuild switch --flake "$HOME/dotfiles#alderbook"''
    else if isLinux
    then ''sudo nixos-rebuild switch --flake "$HOME/dotfiles#${hostname}"''
    else "";

  manual.manpages.enable = true;
  programs.man.enable = true;
  programs.home-manager.enable = true;
  fonts.fontconfig.enable = true;

  # ── ZSH ──────────────────────────────────────────
  programs.zsh = {
    enable = true;
    enableCompletion = false;

    initContent = ''
      if [ -f "$HOME/.p10k.zsh" ]; then
        source "$HOME/.p10k.zsh"
      fi
      source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
      export OPENCODE_API_KEY="$(cat "$HOME/.local/share/sops/age/secrets/opencode-api-key" 2>/dev/null || true)"
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

  # ── Git ──────────────────────────────────────────
  programs.git = {
    enable = true;
    signing = lib.mkIf isDarwin {
      key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF5WXSF7FL2yTpqQjsZlSkIkvs7KqYxovtj3qWP72ayH";
      signByDefault = true;
      format = "openpgp";
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
      core = {
        editor = "nvim";
        fsmonitor = true;
        untrackedcache = true;
      };
      fetch.prune = true;
      grep.lineNumber = true;
      help.autocorrect = 1;
      pull.rebase = true;
    };
    ignores = [
      "[._]*.s[a-v][a-z]"
      "[._]*.sw[a-p]"
      "[._]s[a-v][a-z]"
      "[._]sw[a-p]"
      ".aider*"
      ".DS_Store"
      "**/.DS_Store"
      ".env*"
      "**/.env*"
    ];
  };

  # ── Imports ──────────────────────────────────────
  imports = [
    ./modules/sops.nix
    ./modules/bat.nix
    ./modules/nvim.nix
    ./modules/fzf.nix
    ./modules/delta.nix
    ./modules/ripgrep.nix
    ./modules/zoxide.nix
    ./modules/direnv.nix
    ./modules/tmux.nix
  ] ++ lib.optionals isDarwin [
    ./modules/ghostty.nix
  ];
}
