{
  config,
  pkgs,
  ...
}:

# The macOS Dock points to /Applications/Alacritty.app, a manually created
# symlink to /Users/zberman/.nix-profile/Applications/Alacritty.app. Going
# through the profile keeps it current across Home Manager upgrades.

pkgs.lib.optionalAttrs (pkgs.stdenv.isDarwin) {
  programs.alacritty = {
    enable = true;

    settings = {
      general.import = [
        ./catppuccin_mocha.toml
      ];

      env.SHELL = "${pkgs.bashInteractive}/bin/bash";

      terminal.shell = {
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
