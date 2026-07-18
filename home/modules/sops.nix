{
  config,
  inputs,
  lib,
  ...
}:
{
  imports = [ inputs.sops-nix.homeManagerModules.sops ];

  sops = {
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    defaultSopsFile = ../../secrets/personal.yaml;

    secrets = {
      opencode-api-key = { };
      openrouter-api-key = { };
    };
  };

  home.sessionVariables = {
    SOPS_AGE_KEY_FILE = config.sops.age.keyFile;
    OPENCODE_API_KEY_FILE = config.sops.secrets.opencode-api-key.path;
    OPENROUTER_API_KEY_FILE = config.sops.secrets.openrouter-api-key.path;
  };

  programs.zsh.initContent = lib.mkAfter ''
    opencode() {
      if [[ -r "$OPENCODE_API_KEY_FILE" ]]; then
        OPENCODE_API_KEY="$(<"$OPENCODE_API_KEY_FILE")" command opencode "$@"
      else
        command opencode "$@"
      fi
    }

    pi() {
      if [[ -r "$OPENROUTER_API_KEY_FILE" ]]; then
        OPENROUTER_API_KEY="$(<"$OPENROUTER_API_KEY_FILE")" command pi "$@"
      else
        command pi "$@"
      fi
    }
  '';
}
