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
      enable = false;
      ensureDatabases = [ "matrix-synapse" ];
      ensureUsers = [{
        name = "matrix-synapse";
        ensureDBOwnership = true;
      }];
    };

    matrix-synapse = {
      enable = false;
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

  # ── Hermes Agent (NixOS module) ───────────────────────────────
  services.hermes-agent = {
    enable = false;
    container.enable = true;
    container.image = "ubuntu:26.04";
    container.hostUsers = [ "${username}" ];
    extraDependencyGroups = [ "matrix" "voice" ];
    addToSystemPackages = true;
    stateDir = "/srv/hermes-data";
    settings = {
      model.default = "deepseek-v4-flash";
      model.provider = "opencode-go";
      terminal.cwd = "/data/workspace";
      agent.restart_drain_timeout = 60;
      autonomy.shell_env_passthrough = [ "GH_TOKEN" "GITHUB_TOKEN" ];
    };
    environmentFiles = [ config.sops.secrets.hermes-env.path ];
    restartSec = 5;
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
