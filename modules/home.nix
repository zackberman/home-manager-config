{
  flake.modules.homeManager.home = { lib, pkgs, ... }: {
    # Keep program configuration under ~/.config on macOS too.
    xdg.enable = true;

    programs.karabiner.enable = lib.mkIf pkgs.stdenv.isDarwin true;
  };
}
