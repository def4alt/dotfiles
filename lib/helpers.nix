{
  inputs,
  stateVersion,
  ...
}:
{
  mkDarwin =
    {
      hostname,
      username ? "def4alt",
      platform ? "aarch64-darwin",
      overlays ? [ ],
    }:
    inputs.nix-darwin.lib.darwinSystem {
      specialArgs = {
        inherit
          inputs
          hostname
          platform
          username
          ;
      };
      modules = [
        { nixpkgs.overlays = overlays; }
        ../hosts/alderbook
        inputs.nix-homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew = {
            enable = true;
            enableRosetta = false;
            user = username;
            mutableTaps = true;
            autoMigrate = true;
          };
        }
        inputs.home-manager.darwinModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.${username} = import ../home;
            extraSpecialArgs = {
              inherit
                inputs
                hostname
                platform
                stateVersion
                username
                ;
            };
          };
        }
      ];
    };

  mkHome =
    {
      hostname,
      username ? "def4alt",
      platform ? "x86_64-linux",
      overlays ? [ ],
    }:
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = import inputs.nixpkgs {
        system = platform;
        inherit overlays;
        config.allowUnfree = true;
      };
      extraSpecialArgs = {
        inherit
          hostname
          inputs
          platform
          stateVersion
          username
          ;
      };
      modules = [ ../home ];
    };

  forAllSystems = inputs.nixpkgs.lib.genAttrs [
    "aarch64-linux"
    "aarch64-darwin"
    "x86_64-linux"
  ];
}
