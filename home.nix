{
  config,
  pkgs,
  system,
  username,
  homeDirectory,
  stateVersion,
  ...
}:

{
  imports = [
    ./packages.nix
    ./programs.nix
  ];

  home.username      = username;
  home.homeDirectory = homeDirectory;

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

  # This is to ensure programs are using ~/.config rather than
  # /Users/<username>/Library/whatever
  xdg.enable = true;

}
