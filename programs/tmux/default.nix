{
  pkgs,
  isWSL,
  ...
}:

{
  programs.tmux =
    # I believe I originally did this so that I could reroute specific
    # C-PageUp/C-PageDown via Karabiner
    let
      isDarwin       = pkgs.stdenv.isDarwin;
      prevWinBinding = if isDarwin then "M-1" else "C-PageUp";
      nextWinBinding = if isDarwin then "M-2" else "C-PageDown";

      # https://github.com/microsoft/WSL/issues/5931
      escapeTime     = if isWSL then 1 else 0;

    in {
      enable = true;

      sensibleOnTop = false;

      # ported from my .tmux.conf:
      extraConfig = ''
        bind -n M-h select-pane -L
        bind -n M-l select-pane -R
        bind -n M-k select-pane -U
        bind -n M-j select-pane -D
        bind -n ${prevWinBinding} previous-window
        bind -n ${nextWinBinding} next-window

        set-option -g allow-rename off
        
        # tmux starts a login shell by default; this overrides that
        set-option -g default-command "$SHELL"

        # No delay after pressing escape in VIM
        set -sg escape-time ${builtins.toString escapeTime}
      '';

      terminal = "screen-256color"; # set -g default-terminal "screen-256color"

      inherit escapeTime;
    };
}
