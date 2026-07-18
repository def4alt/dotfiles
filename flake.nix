{
  description = "Def4alt's Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin/nix-darwin-26.05";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew = {
      url = "github:zhaofengli-wip/nix-homebrew";
      inputs.brew-src.url = "github:Homebrew/brew/master";
    };
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{ nixpkgs, ... }:
    let
      stateVersion = "24.11";
      helpers = import ./lib { inherit inputs stateVersion; };
      overlays = [
        (_final: previous: {
          inherit (inputs.nixpkgs-unstable.legacyPackages.${previous.stdenv.hostPlatform.system})
            pi-coding-agent
            ;
        })
      ];
    in
    {
      homeConfigurations."def4alt@alderbook" = helpers.mkHome {
        hostname = "alderbook";
        platform = "aarch64-darwin";
        inherit overlays;
      };

      darwinConfigurations.alderbook = helpers.mkDarwin {
        hostname = "alderbook";
        platform = "aarch64-darwin";
        inherit overlays;
      };

      formatter = helpers.forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-tree);
    };
}
