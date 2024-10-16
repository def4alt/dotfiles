{
  programs.ripgrep = {
    enable = true;
    arguments = [
      "--color=always"
      "--column"
      "--hidden"
      "--line-number"
      "--no-heading"
      "--smart-case"
      "--glob=!*.{min.js,swp,o,zip}"
      "--glob=!{.cache,.git,node_modules,vendor}/*"
    ];
  };
}
