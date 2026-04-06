{ config, lib, pkgs, inputs, username, ... }:

let
  # Your age public key from age-keygen
  agePublicKey = "age1h5hqy6aupk6j5v522nv3jhtuq0cwp086jdc25fmujn8r9spd0e4szx559u";
in {
  imports = [ inputs.sops-nix.homeManagerModules.sops ];

  sops = {
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";

    defaultSopsFile = ./secrets.yaml;

    secrets.opencode-api-key = {
      path = "${config.sops.defaultSymlinkPath}/opencode-api-key";
    };
  };

  home.sessionVariables.OPENCODE_API_KEY = "${config.sops.secrets.opencode-api-key.path}";
}
