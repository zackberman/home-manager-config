{ inputs, ... }:
{
  flake.modules.homeManager.packages = { pkgs, ... }: {
    home.packages = [
      pkgs.bat
      pkgs.bashInteractive
      pkgs.coreutils-prefixed
      pkgs.curl
      pkgs.delta
      pkgs.docker
      pkgs.duf
      pkgs.dust
      pkgs.eza
      pkgs.fzf
      pkgs.git
      pkgs.htop
      pkgs.nodejs
      pkgs.nix-tree
      pkgs.ollama
      pkgs.openssh_gssapi
      pkgs.ripgrep
      pkgs.rustfmt
      pkgs.screen
      pkgs.tig
      (pkgs.python3.withPackages (ps: [ ps.ipython ]))
      inputs.nytxw-stats.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
  };
}
