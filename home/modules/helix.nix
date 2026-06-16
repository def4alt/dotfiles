{
  programs.helix = {
    enable = true;
    extraConfig = ''
      theme = "kanagawa-dragon"

      [editor]
      mouse = false
      line-number = "relative"
      rulers = [100]
      true-color = true

      [editor.indent-guides]
      character = "╎"
      render = true

      [editor.inline-diagnostics]
      cursor-line = "warning"
      other-lines = "hint"

      [editor.statusline]
      left = ["mode", "spinner", "version-control", "file-name"]
    '';
  };
}
