{ config, lib, pkgs, inputs, username, ... }:

let
  # Your age public key from age-keygen
  agePublicKey = "age1h5hqy6aupk6j5v522nv3jhtuq0cwp086jdc25fmujn8r9spd0e4szx559u";
  # Hardcoded path - sops-nix uses this default symlink path
  secretPath = "${config.home.homeDirectory}/.local/share/sops/age/secrets/opencode-api-key";
in {
  imports = [ inputs.sops-nix.homeManagerModules.sops ];

  sops = {
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";

    defaultSopsFile = ./secrets.yaml;

    secrets.opencode-api-key = {
      path = secretPath;
    };
  };

  # Expose path first, then load value in shell init
  home.sessionVariables = {
    OPENCODE_API_KEY_FILE = secretPath;
  };

  programs.zsh.initContent = ''
    if [ -f "$OPENCODE_API_KEY_FILE" ]; then
      export OPENCODE_API_KEY="$(cat "$OPENCODE_API_KEY_FILE")"
    fi
  '';
}
