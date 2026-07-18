{
  inputs,
  stateVersion,
  ...
}:
let
  helpers = import ./helpers.nix { inherit inputs stateVersion; };
in
{
  inherit (helpers) mkDarwin;
}
