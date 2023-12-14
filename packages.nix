{
  config,
  pkgs,
  ...
}:

{
  home.packages = [
    pkgs.bat
    pkgs.bashInteractive
    pkgs.delta
    pkgs.eza
    pkgs.fzf
    pkgs.git
    pkgs.htop
    pkgs.nix-tree
    pkgs.openssh
    pkgs.ripgrep
    pkgs.tig
    pkgs.vim
  ];
}
