{
  description = "Def4alt's Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
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
    inherit (helper.forAllSystems (system: nixpkgs.legacyPackages.${system}.stdenv)) isLinux;
  in {
    homeConfigurations =
      if isLinux
      then {
        "andriiolkhovych@alderbook" = helper.mkHome {
          hostname = "alderbook";
          platform = "aarch64-darwin";
        };
      }
      else {};

    darwinConfigurations = {
      alderbook = helper.mkDarwin {
        hostname = "alderbook";
        platform = "aarch64-darwin";
      };
    };

    formatter =
      helper.forAllSystems (system:
        nixpkgs.legacyPackages.${system}.nixfmt-rfc-style);
  };
}
