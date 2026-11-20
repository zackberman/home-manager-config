{
  flake.modules.homeManager.home = {
    # Keep program configuration under ~/.config on macOS too.
    xdg.enable = true;
  };
}
