{ config,
  pkgs,
  system,
  username,
  homeDirectory,
  stateVersion,
  ...
}:

{
  home.username      = username;
  home.homeDirectory = homeDirectory;

  home.packages = [
    pkgs.bat
    pkgs.bashInteractive
    pkgs.delta
    pkgs.eza
    pkgs.fzf
    pkgs.git
    pkgs.htop
    pkgs.ripgrep
    pkgs.tig
    pkgs.vim
  ];

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = stateVersion;

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}

// (pkgs.lib.attrsets.optionalAttrs pkgs.stdenv.isDarwin {

  # This is to ensure programs are using ~/.config rather than
  # /Users/<username>/Library/whatever
  xdg.enable = true;

  programs.bash = {
    enable = true;
    initExtra = ''
      function ll() { eza -algF --group-directories-first "$@"; }

      #source "$(fzf-share)/key-bindings.bash"
      #source "$(fzf-share)/completion.bash"
    '';

    shellAliases = {
      dirs = "dirs -v";
    };

    # don't put duplicate lines or lines starting with space in the history
    historyControl = [ "ignoredups" "ignorespace" ];

    sessionVariables = {
      DISPLAY = ":0";
    };
  };

  programs.fzf = 
    let defaultCommand = ''
      rg --files --no-ignore --hidden --follow -g "!{.git,node_modules}/*" 2> /dev/null
    '';

    in {
      enable = true;

      # export FZF_DEFAULT_COMMAND='rg --files --no-ignore --hidden --follow -g "!{.git,node_modules}/*" 2> /dev/null'
      inherit defaultCommand;

      # export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
      fileWidgetCommand = defaultCommand;
    };

  programs.starship = {
    enable = true;
    settings = {
      battery.disabled = true;
    };
  };

  programs.tmux = {
    enable = true;

    sensibleOnTop = false;

    # ported from my .tmux.conf:
    extraConfig = ''
      bind -n M-h select-pane -L
      bind -n M-l select-pane -R
      bind -n M-k select-pane -U
      bind -n M-j select-pane -D

      # I believe these are rerouted from PageUp/PageDown via Karabiner
      bind -n M-1 previous-window
      bind -n M-2 next-window
      #bind -n C-PageUp previous-window
      #bind -n C-PageDown next-window

      set-option -g allow-rename off
      
      # tmux starts a login shell by default; this overrides that
      set-option -g default-command "$SHELL"

      set -sg escape-time 0 # No delay after pressing escape in VIM
    '';

    terminal = "screen-256color"; # set -g default-terminal "screen-256color"

    escapeTime = 0;
  };
})
