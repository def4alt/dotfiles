{
  programs.delta = {
    enable = true;

    enableGitIntegration = true;

    options = {
      features = "unobtrusive-line-numbers decorations";
      syntax-theme = "Monokai Extended Bright";
      whitespace-error-style = "22 reverse";

      decorations = {
        commit-decoration-style = "bold yellow box ul";
        file-decoration-style = "none";
        file-style = "bold yellow ul";
        hunk-header-decoration-style = "yellow box";
      };

      unobtrusive-line-numbers = {
        line-numbers = true;
        line-numbers-left-format = "{nm:>4}┊";
        line-numbers-left-style = "#444444";
        line-numbers-minus-style = "#444444";
        line-numbers-plus-style = "#444444";
        line-numbers-right-format = "{np:>4}│";
        line-numbers-right-style = "#444444";
        line-numbers-zero-style = "#444444";
      };
    };
  };
}
