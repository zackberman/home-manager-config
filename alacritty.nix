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
        "${pkgs.alacritty-theme}/catppuccin_mocha.yaml"
      ];
    };
  };
}
