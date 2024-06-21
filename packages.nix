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
      pkgs.curl
      pkgs.delta
      pkgs.docker
      pkgs.eza
      pkgs.fzf
      pkgs.git
      pkgs.htop
      pkgs.nix-tree
      pkgs.ollama
      pkgs.openssh
      pkgs.ripgrep
      pkgs.screen
      pkgs.tig
      python
      nytxw-stats.default
    ];
  }
