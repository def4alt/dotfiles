{
  inputs,
  outputs,
  stateVersion,
  ...
}: {
  mkDarwin = {
    hostname,
    username ? "andriiolkhovych",
    platform ? "aarch64-darwin",
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
    username ? "andriiolkhovych",
    platform ? "x86_64-linux",
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
      modules = [../home];
    };

  forAllSystems = inputs.nixpkgs.lib.genAttrs [
    "aarch64-linux"
    "aarch64-darwin"
    "x86_64-linux"
  ];
}
