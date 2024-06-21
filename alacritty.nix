{
  config,
  pkgs,
  ...
}:

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
