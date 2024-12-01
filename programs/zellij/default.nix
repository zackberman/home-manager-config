{
  pkgs,
  isWSL,
  ...
}:

{
  programs.zellij =

    # TODO: this is copied verbatim from tmux/default.nix. It's unused but
    # possibly could be helpful?

    # I believe I originally did this so that I could reroute specific
    # C-PageUp/C-PageDown via Karabiner
    let
      isDarwin       = pkgs.stdenv.isDarwin;
      prevWinBinding = if isDarwin then "M-1" else "C-PageUp";
      nextWinBinding = if isDarwin then "M-2" else "C-PageDown";

      # https://github.com/microsoft/WSL/issues/5931
      escapeTime     = if isWSL then 1 else 0;

    in {
      enable                = true;
      enableBashIntegration = false;

      settings = {

        default_shell = "${pkgs.bashInteractive}/bin/bash";

        # Mouse mode interferes with my ability to select text
        mouse_mode = false;

        theme = "terafox";

        keybinds = {

          locked = {
            "unbind \"Ctrl g\"" = {};
            "bind \"Alt ;\"" = { SwitchToMode   = { _args = [ "Normal"  ]; }; };
          };

          shared = {
            "bind \"Alt h\"" = { MoveFocusOrTab = { _args = [ "Left"    ]; }; };
            "bind \"Alt l\"" = { MoveFocusOrTab = { _args = [ "Right"   ]; }; };
            "bind \"Alt j\"" = { MoveFocus      = { _args = [ "Down"    ]; }; };
            "bind \"Alt k\"" = { MoveFocus      = { _args = [ "Up"      ]; }; };
          };

          "shared_except \"locked\"" = {
            "unbind \"Ctrl g\"" = {};
            "bind \"Alt ;\"" = { SwitchToMode   = { _args = [ "Locked"  ]; }; };
          };
        };

      };
    };
}
