{ config, lib, pkgs, inputs, outputs, hostname, username, stateVersion, ... }:

{
  # ── Cloudflare Tunnel ──
  # Credentials are stored in secrets.yaml (sops-encrypted)

  imports = [
    inputs.disko.nixosModules.disko
    ./disko.nix
    inputs.sops-nix.nixosModules.sops
    inputs.home-manager.nixosModules.home-manager
  ];

  sops = {
    defaultSopsFile = ./secrets.yaml;
    age.keyFile = "/home/${username}/.config/sops/age/keys.txt";
    secrets = {
      gh-token = {};
      opencode-go-api-key = {};
      groq-api-key = {};
      matrix-access-token = {};
      matrix-recovery-key = {};
      matrix-registration-secret = {};
      tailscale-auth-key = {};
      cloudflared-credentials = {
        path = "/etc/cloudflared/2cb58440-fe33-4724-97ec-127086415088.json";
      };
    };
  };

  nixpkgs.config.allowUnfree = true;

  nix = {
    package = pkgs.nix;
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
    optimise.automatic = true;
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
    };
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking = {
    hostName = hostname;
    networkmanager.enable = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 ];
      allowedUDPPortRanges = [
        { from = 60000; to = 61000; } # Mosh
      ];
    };
  };

  virtualisation.docker.enable = true;

  environment.systemPackages = with pkgs; [ cloudflared mosh ];

  programs.zsh.enable = true;

  services = {
    tailscale = {
      enable = true;
      authKeyFile = config.sops.secrets.tailscale-auth-key.path;
    };
    openssh.enable = true;

    matrix-synapse = {
      enable = true;
      settings = {
        server_name = "zorya";
        listeners = [{
          port = 8008;
          bind_addresses = [ "0.0.0.0" "::" ];
          type = "http";
          tls = false;
          x_forwarded = true;
          resources = [{
            names = [ "client" "federation" ];
            compress = false;
          }];
        }];
        suppress_key_server_warning = true;
        trusted_key_servers = [{ server_name = "matrix.org"; }];
      };
    };
  };

  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" "networkmanager" ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF5WXSF7FL2yTpqQjsZlSkIkvs7KqYxovtj3qWP72ayH"
    ];
  };

  swapDevices = [{
    device = "/swapfile";
    size = 2048;
  }];

  # ── Cloudflare Tunnel ──────────────────────────────────────
  systemd.services.cloudflared-tunnel = {
    description = "Cloudflare Tunnel for matrix.def4alt.com";
    after = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = ''${pkgs.cloudflared}/bin/cloudflared tunnel run --protocol auto 2cb58440-fe33-4724-97ec-127086415088'';
      Restart = "always";
      RestartSec = "10";
    };
  };

  # ── Hermes env generator ────────────────────────────────────
  systemd.services.hermes-env = {
    description = "Write Hermes .env from SOPS secrets";
    before = [ "hermes-agent.service" ];
    requiredBy = [ "hermes-agent.service" ];
    serviceConfig = {
      Type = "oneshot";
      User = username;
      Group = username;
    };
    script = ''
      mkdir -p /srv/hermes-data/.hermes
      cat > /srv/hermes-data/.hermes/.env << EOF
      GH_TOKEN=$(cat ${config.sops.secrets.gh-token.path})
      OPENCODE_GO_API_KEY=$(cat ${config.sops.secrets.opencode-go-api-key.path})
      OPENCODE_API_KEY=$(cat ${config.sops.secrets.opencode-go-api-key.path})
      GROQ_API_KEY=$(cat ${config.sops.secrets.groq-api-key.path})
      MATRIX_HOMESERVER=http://127.0.0.1:8008
      MATRIX_ACCESS_TOKEN=$(cat ${config.sops.secrets.matrix-access-token.path})
      MATRIX_ALLOWED_USERS=@def4alt:zorya
      MATRIX_RECOVERY_KEY=$(cat ${config.sops.secrets.matrix-recovery-key.path})
      EOF
    '';
  };

  # ── Hermes Agent container ──────────────────────────────────
  systemd.services.hermes-agent = {
    description = "Hermes Gateway";
    after = [ "network-online.target" "docker.service" "hermes-env.service" "matrix-synapse.service" ];
    wants = [ "network-online.target" ];
    unitConfig.RequiresMountsFor = "/srv/hermes-data";
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      ExecStartPre = "-${pkgs.docker}/bin/docker rm -f hermes";
      ExecStart = ''${pkgs.docker}/bin/docker run --name hermes \
        --rm \
        --shm-size=1g \
        -p 127.0.0.1:8642:8642 \
        -v /srv/hermes-data:/opt/data \
        --env-file /srv/hermes-data/.hermes/.env \
        nousresearch/hermes-agent:latest gateway run'';
      ExecStop = "${pkgs.docker}/bin/docker stop hermes";
      ExecStopPost = "-${pkgs.docker}/bin/docker rm -f hermes";
      Restart = "always";
      RestartSec = "10";
    };
  };

  system.stateVersion = stateVersion;
  nixpkgs.hostPlatform = "x86_64-linux";

  # ── Home Manager ────────────────────────────────────────────
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.${username} = lib.mkMerge [
      (import ../../home)
    ];
    extraSpecialArgs = {
      inherit inputs outputs hostname username stateVersion;
      platform = "x86_64-linux";
    };
  };
}
