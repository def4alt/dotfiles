{ config, lib, pkgs, inputs, outputs, hostname, username, stateVersion, ... }:

{
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
      tailscale-auth-key = {};
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
      allowedTCPPorts = [ 22 80 443 ];
      allowedUDPPortRanges = [
        { from = 60000; to = 61000; } # Mosh
      ];
    };
  };

  virtualisation.docker.enable = true;

  environment.systemPackages = with pkgs; [ mosh kubectl ];

  programs.zsh.enable = true;

  services = {
    tailscale = {
      enable = true;
      authKeyFile = config.sops.secrets.tailscale-auth-key.path;
    };
    openssh.enable = true;

    k3s = {
      enable = true;
      role = "server";
      tokenFile = "/var/lib/rancher/k3s/server/token";
      extraFlags = toString [
        "--write-kubeconfig-mode \"0644\""
        "--cluster-init"
        "--disable servicelb"
        "--disable traefik"
        "--kubelet-arg=max-pods=150"
        "--kube-apiserver-arg=event-ttl=72h"
        "--etcd-arg=quota-backend-bytes=4294967296"
        "--etcd-arg=auto-compaction-mode=periodic"
        "--etcd-arg=auto-compaction-retention=24h"
        "--etcd-snapshot-schedule-cron=0 */6 * * *"
        "--etcd-snapshot-retention=28"
        "--etcd-snapshot-compress"
      ];
      clusterInit = true;
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
