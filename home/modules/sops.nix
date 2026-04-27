{ config, lib, pkgs, inputs, username, ... }:

let
  # Your age public key from age-keygen
  agePublicKey = "age1h5hqy6aupk6j5v522nv3jhtuq0cwp086jdc25fmujn8r9spd0e4szx559u";
  # Hardcoded paths - sops-nix uses these default symlink paths
  opencodeSecretPath = "${config.home.homeDirectory}/.local/share/sops/age/secrets/opencode-api-key";
  openrouterSecretPath = "${config.home.homeDirectory}/.local/share/sops/age/secrets/openrouter-api-key";
in {
  imports = [ inputs.sops-nix.homeManagerModules.sops ];

  sops = {
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";

    defaultSopsFile = ./secrets.yaml;

    secrets.opencode-api-key = {
      path = opencodeSecretPath;
    };

    secrets.openrouter-api-key = {
      path = openrouterSecretPath;
    };
  };

  # Expose path first so shell startup stays light
  home.sessionVariables = {
    OPENCODE_API_KEY_FILE = opencodeSecretPath;
    OPENROUTER_API_KEY_FILE = openrouterSecretPath;
  };

}
