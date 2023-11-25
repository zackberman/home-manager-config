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
    pkgs.ripgrep
    pkgs.tig
    pkgs.vim
  ];
}
