{
  inputs,
  outputs,
  stateVersion,
  ...
}: {
  mkDarwin = {
    hostname,
    username ? "def4alt",
    platform ? "aarch64-darwin",
    overlays ? [],
  }:
    inputs.nix-darwin.lib.darwinSystem {
      specialArgs = {
        inherit
          inputs
          outputs
          platform
          hostname
          username
          ;
      };
      modules = [
        {
          nixpkgs.overlays = overlays;
        }
        ../darwin
        inputs.nix-homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew = {
            enable = true;
            enableRosetta = false;
            user = "${username}";
            mutableTaps = true;
            autoMigrate = true;
          };
        }
        inputs.home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users."${username}" = import ../home;

          home-manager.extraSpecialArgs = {
            inherit
              inputs
              outputs
              hostname
              platform
              username
              stateVersion
              ;
          };
        }
      ];
    };

  mkHome = {
    hostname,
    username ? "def4alt",
    platform ? "x86_64-linux",
    overlays ? [],
  }:
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = inputs.nixpkgs.legacyPackages.${platform};
      extraSpecialArgs = {
        inherit
          inputs
          outputs
          hostname
          platform
          username
          stateVersion
          ;
      };
      modules = [
        {
          nixpkgs.overlays = overlays;
        }
        ../home
      ];
    };

  forAllSystems = inputs.nixpkgs.lib.genAttrs [
    "aarch64-linux"
    "aarch64-darwin"
    "x86_64-linux"
  ];
}
