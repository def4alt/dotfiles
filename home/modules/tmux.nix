{
  programs.tmux = {
    enable = true;
    clock24 = true;
    terminal = "screen-256color";
    extraConfig = ''
      unbind C-b
      set -g prefix C-Space
      bind-key C-Space send-prefix

      set -g extended-keys-format csi-u
      set -g extended-keys on
      set -g mouse on
      set -g history-limit 100000
      set -g base-index 1
      setw -g pane-base-index 1
      set -g renumber-windows on
      set -sg escape-time 0

      bind c new-window -c "#{pane_current_path}"
      bind '"' split-window -v -c "#{pane_current_path}"
      bind % split-window -h -c "#{pane_current_path}"
    '';
  };
}
