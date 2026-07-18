{
  lib,
  pkgs,
  username,
  hostname,
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

    packages =
      with pkgs;
      [
        coreutils
        wget
        lua
        luarocks
        ncdu
        fd
        qpdf
        lazygit
        python3
        nodejs-slim
        pnpm
        pi-coding-agent
        gh
        pay-respects
        age
        sops
        sshpass
        devenv
        yt-dlp
        qemu
        ffmpeg
      ]
      ++ lib.optionals isLinux [
        docker
        opencode
      ];

    sessionPath = [
      "$HOME/.local/bin"
      "$HOME/.local/share/pnpm"
    ];

    sessionVariables = {
      EDITOR = "nvim";
      SYSTEMD_EDITOR = "nvim";
      VISUAL = "nvim";
      PNPM_HOME = "$HOME/.local/share/pnpm";
      PNPM_CONFIG_GLOBAL_DIR = "$HOME/.local/share/pnpm/global";
      SOPS_AGE_KEY_FILE = "$HOME/.config/sops/age/keys.txt";
    }
    // lib.optionalAttrs isLinux {
      KUBECONFIG = "/etc/rancher/k3s/k3s.yaml";
    };
  };

  home.shellAliases = {
    ll = "ls -lah";
    cat = "bat";
    update =
      if isDarwin then
        ''sudo darwin-rebuild switch --flake "$HOME/dotfiles#alderbook"''
      else if isLinux then
        ''sudo nixos-rebuild switch --flake "$HOME/dotfiles#${hostname}"''
      else
        "";
  };

  manual.manpages.enable = true;
  fonts.fontconfig.enable = true;

  programs = {
    man.enable = true;
    home-manager.enable = true;

    zsh = {
      enable = true;
      enableCompletion = false;

      initContent = ''
        if [ -f "$HOME/.p10k.zsh" ]; then
          source "$HOME/.p10k.zsh"
        fi
        source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
        export OPENCODE_API_KEY="$(cat "$HOME/.local/share/sops/age/secrets/opencode-api-key" 2>/dev/null || true)"
        export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"
      '';
    };
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
      core = {
        editor = "nvim";
        untrackedcache = true;
      };
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
    ./modules/bat.nix
    ./modules/nvim.nix
    ./modules/fzf.nix
    ./modules/delta.nix
    ./modules/ripgrep.nix
    ./modules/zoxide.nix
    ./modules/direnv.nix
    ./modules/tmux.nix
    ./modules/helix.nix
    ./modules/ssh.nix
  ]
  ++ lib.optionals isDarwin [
    ./modules/ghostty.nix
  ];
}
