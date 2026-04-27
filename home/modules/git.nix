{
  programs.git = {
    enable = true;
    signing.key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF5WXSF7FL2yTpqQjsZlSkIkvs7KqYxovtj3qWP72ayH";
    signing.signByDefault = true;
    signing.format = "openpgp";
    settings = {
      user = {
        name = "Andrii Olkhovych";
        email = "andrii.olkhovych@tum.de";
      };

      init.defaultBranch = "main";
      push.autoSetupRemote = true;
      gpg.format = "ssh";
      gpg.ssh.program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
      core = {
        editor = "nvim";
        fsmonitor = true;
        untrackedcache = true;
      };
      fetch.prune = true;
      grep.lineNumber = true;
      help.autocorrect = 1;
      pull.rebase = true;
    };
    ignores = [
      # Swap
      "[._]*.s[a-v][a-z]"
      "[._]*.sw[a-p]"
      "[._]s[a-v][a-z]"
      "[._]sw[a-p]"
      ".aider*"
      # System
      ".DS_Store"
      "**/.DS_Store"
      # Env
      ".env*"
      "**/.env*"
    ];
  };
}
