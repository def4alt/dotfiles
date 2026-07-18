{
  programs = {
    bash = {
      enable = true;
      enableCompletion = true;
      historyControl = [
        "erasedups"
        "ignorespace"
      ];
      historyFileSize = 100000;
      historySize = 10000;
      shellOptions = [
        "checkjobs"
        "checkwinsize"
        "cmdhist"
        "extglob"
        "globstar"
        "histappend"
      ];
    };

    oh-my-posh = {
      enable = true;
      enableBashIntegration = true;
      useTheme = "powerlevel10k_lean";
    };

    readline = {
      enable = true;
      bindings = {
        "\\e[A" = "history-search-backward";
        "\\e[B" = "history-search-forward";
      };
      variables = {
        colored-stats = true;
        completion-ignore-case = true;
        mark-symlinked-directories = true;
        show-all-if-ambiguous = true;
        visible-stats = true;
      };
    };
  };
}
