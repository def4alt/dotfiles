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
            user = username;
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

}
