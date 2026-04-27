{...}: {
  programs.ghostty = {
    enable = true;
    package = null;
    settings = {
      theme = "tokyonight";
      "font-size" = 18;
      "font-family" = "JetBrains Mono";
      "mouse-hide-while-typing" = true;
      "window-padding-x" = 10;
      "window-padding-y" = 4;
      keybind = [ "shift+enter=text:\\x1b\\r" ];
      command = "zsh -lic \"tmux new-session -A -s main\"";
      "macos-titlebar-style" = "native";
    };
  };
}
