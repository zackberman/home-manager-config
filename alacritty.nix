{
  config,
  pkgs,
  ...
}:

# Note to self: the Alacritty in my macOS dock is an alias to the Alacritty I've
# installed in the nix store. Maybe I could automate this, but for now I
# maintain this manually. This means that when I update nixpkgs and get a new
# Alacritty, I need to do the following:
#
#   * Open the folder containing Alacritty.app like so:
#       open "$(dirname $(realpath $(type -p alacritty)))"/../Applications/
#   * Make a macOS alias to Alacritty.app in my Applications directory in Finder
#   * Remove the existing Alacritty app from my dock
#   * Drag and drop the macOS alias to my dock

pkgs.lib.optionalAttrs (pkgs.stdenv.isDarwin) {
  programs.alacritty = {
    enable = true;

    settings = {
      import = [
        "${pkgs.alacritty-theme}/catppuccin_mocha.toml"
      ];

      shell = {
        program = "${pkgs.bashInteractive}/bin/bash";
        args    = [ "-l" ];
      };

      cursor = {
        style.shape       = "Block";
        style.blinking    = "On";
      };

      font = {
        size = 12.0;

        normal.family     = "JetBrainsMono Nerd Font";

        normal.style      = "ExtraLight";
        italic.style      = "ExtraLight Italic";
        bold.style        = "ExtraLight";
        bold_italic.style = "ExtraLight Italic";
      };

      selection = {
        save_to_clipboard = true;
      };

      window = {
        option_as_alt     = "Both";
        startup_mode      = "Maximized";
      };
    };
  };
}
