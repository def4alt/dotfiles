_: {
  programs.direnv = {
    enable = true;
    config.global = {
      hide_env_diff = true;
      log_format = "direnv: %s";
    };
    nix-direnv.enable = true;
  };
}
