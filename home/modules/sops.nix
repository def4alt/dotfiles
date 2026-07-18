{
  config,
  inputs,
  ...
}:

let
  opencodeSecretPath = "${config.home.homeDirectory}/.local/share/sops/age/secrets/opencode-api-key";
  openrouterSecretPath = "${config.home.homeDirectory}/.local/share/sops/age/secrets/openrouter-api-key";
in
{
  imports = [ inputs.sops-nix.homeManagerModules.sops ];

  sops = {
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";

    defaultSopsFile = ./secrets.yaml;

    secrets = {
      opencode-api-key.path = opencodeSecretPath;
      openrouter-api-key.path = openrouterSecretPath;
    };
  };

  home.sessionVariables = {
    OPENCODE_API_KEY_FILE = opencodeSecretPath;
    OPENROUTER_API_KEY_FILE = openrouterSecretPath;
  };
}
