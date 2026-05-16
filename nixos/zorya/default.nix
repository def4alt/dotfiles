{ config, lib, pkgs, inputs, outputs, hostname, username, stateVersion, ... }:

{
  # ── Cloudflare Tunnel ──
  # Credentials are stored in secrets.yaml (sops-encrypted)

  imports = [
    ./hardware-configuration.nix
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
      hermes-access-token = {};
      hermes-env = {
        format = "yaml";
      };
      matrix-registration-secret = {
        owner = "matrix-synapse";
      };
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

    postgresql = {
      enable = true;
      ensureDatabases = [ "matrix-synapse" ];
      ensureUsers = [{
        name = "matrix-synapse";
        ensureDBOwnership = true;
      }];
    };

    matrix-synapse = {
      enable = true;
      settings = {
        server_name = "zorya";
        public_baseurl = "https://matrix.def4alt.com/";
        listeners = [{
          port = 8008;
          bind_addresses = [ "0.0.0.0" ];
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
        registration_shared_secret_path = config.sops.secrets.matrix-registration-secret.path;
      };
    };
  };

  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" "networkmanager" ];
    shell = pkgs.zsh;
    hashedPassword = "$6$0Qwkk0hxmmYhES3K$vPy85rX1OjEq1hwAr97d30uVSd8TVRF88ghPAfGEn49CRPrzSsr5GmTRaf4bcVuZMH8BvyFdvM9ZPouI3B6q31";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF5WXSF7FL2yTpqQjsZlSkIkvs7KqYxovtj3qWP72ayH"
    ];
  };

  swapDevices = [{
    device = "/swapfile";
    size = 2048;
  }];

  # ── Cloudflare Tunnel ──────────────────────────────────────
  environment.etc."cloudflared/config.yml" = {
    text = ''
      tunnel: 2cb58440-fe33-4724-97ec-127086415088
      credentials-file: /etc/cloudflared/2cb58440-fe33-4724-97ec-127086415088.json
      ingress:
        - hostname: matrix.def4alt.com
          service: http://localhost:8008
        - service: http_status:404
    '';
  };

  systemd.services.cloudflared-tunnel = {
    description = "Cloudflare Tunnel for matrix.def4alt.com";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target"];
    serviceConfig = {
      ExecStart = ''${pkgs.cloudflared}/bin/cloudflared tunnel --config /etc/cloudflared/config.yml run'';
      Restart = "always";
      RestartSec = "10";
    };
  };

  # ── ZeroClaw env generator ──────────────────────────────────
  systemd.services.zeroclaw-env = {
    description = "Write ZeroClaw config.toml from SOPS secrets";
    before = [ "zeroclaw.service" ];
    requiredBy = [ "zeroclaw.service" ];
    serviceConfig.Type = "oneshot";
    script = ''
      install -d -m 0755 /srv/hermes-data/zeroclaw/.zeroclaw

      OPENCODE_KEY=$(cat ${config.sops.secrets.opencode-go-api-key.path})
      MATRIX_TOKEN=$(cat ${config.sops.secrets.matrix-access-token.path})

      # Patch the api_key and access_token into the config
      cat > /srv/hermes-data/zeroclaw/.zeroclaw/config.toml << ZC_EOF
      [providers]
      fallback = "opencode-go"

      [providers.models.opencode-go]
      kind = "opencode-go"
      model = "deepseek-v4-flash"
      api_key = "$OPENCODE_KEY"

      [channels.matrix]
      enabled = true
      homeserver = "http://127.0.0.1:8008"
      access_token = "$MATRIX_TOKEN"
      user_id = "@zero:zorya"
      device_id = "ZEROCLAW01"
      allowed_users = ["@def4alt:zorya"]
      ZC_EOF

      chown 65534:65534 /srv/hermes-data/zeroclaw/.zeroclaw/config.toml
      chmod 600 /srv/hermes-data/zeroclaw/.zeroclaw/config.toml
    '';
  };

  # ── ZeroClaw agent container ────────────────────────────────
  systemd.services.zeroclaw = {
    description = "ZeroClaw agent";
    after = [ "network-online.target" "docker.service" "zeroclaw-env.service" "matrix-synapse.service" ];
    wants = [ "network-online.target" ];
    unitConfig.RequiresMountsFor = "/srv/hermes-data";
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      ExecStartPre = "-${pkgs.docker}/bin/docker rm -f zeroclaw";
      ExecStart = ''${pkgs.docker}/bin/docker run --name zeroclaw \
        --rm \
        --network host \
        -v /srv/hermes-data/zeroclaw:/zeroclaw-data \
        ghcr.io/zeroclaw-labs/zeroclaw:latest'';
      ExecStop = "${pkgs.docker}/bin/docker stop zeroclaw";
      ExecStopPost = "-${pkgs.docker}/bin/docker rm -f zeroclaw";
      Restart = "always";
      RestartSec = "10";
    };
  };

  # ── Hermes Agent (NixOS module) ───────────────────────────────
  services.hermes-agent = {
    enable = true;
    extraDependencyGroups = [ "matrix" ];
    addToSystemPackages = false;
    settings = {
      model.default = "deepseek-v4-flash:xhigh";
      model.provider = "opencode-go";
    };
    environmentFiles = [ config.sops.secrets.hermes-env.path ];
  };

  system.stateVersion = stateVersion;

  # ── Home Manager ────────────────────────────────────────────
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.${username} = import ../../home;
    extraSpecialArgs = {
      inherit inputs outputs hostname username stateVersion;
      platform = "x86_64-linux";
    };
  };
}
