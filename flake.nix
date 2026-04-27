{
  description = "Def4alt's Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nix-darwin.url = "github:LnL7/nix-darwin/nix-darwin-25.11";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    nix-darwin,
    nixpkgs,
    ...
  } @ inputs: let
    inherit (self) outputs;
    stateVersion = "24.11";
    helper = import ./lib {inherit inputs outputs stateVersion;};
    overlays = [];
    inherit (helper.forAllSystems (system: nixpkgs.legacyPackages.${system}.stdenv)) isLinux;
  in {
    homeConfigurations =
      if isLinux
      then {
        "def4alt@alderbook" = helper.mkHome {
          hostname = "alderbook";
          platform = "aarch64-darwin";
          inherit overlays;
        };
      }
      else {};

    darwinConfigurations = {
      alderbook = helper.mkDarwin {
        hostname = "alderbook";
        platform = "aarch64-darwin";
        inherit overlays;
      };
    };

    formatter =
      helper.forAllSystems (system:
        nixpkgs.legacyPackages.${system}.nixfmt-rfc-style);
  };
}
