{
  config,
  pkgs,
  nytxw-stats,
  ...
}:

let
  pypkgs =
    ps: with ps; [
      ipython
    ];

  python = pkgs.python3.withPackages pypkgs;

in
  {
    home.packages = [
      pkgs.bat
      pkgs.bashInteractive
      pkgs.coreutils-prefixed
      pkgs.delta
      pkgs.eza
      pkgs.fzf
      pkgs.git
      pkgs.htop
      pkgs.nix-tree
      pkgs.openssh
      pkgs.ripgrep
      pkgs.tig
      python
      nytxw-stats.default
    ];
  }
