{
  description = "Home Manager configuration of zberman";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url          = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Strictly speaking, this flake doesn't require pyproject.nix. But we take
    # it as an input anyway so that we can put it in the nix registry while we
    # build nytxw-stats. That way, when I do local development on nytxw-stats,
    # I can take pyproject.nix as an indirect input.
    pyproject-nix = {
      url = "github:pyproject-nix/pyproject.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nytxw-stats = {
      url = "git+ssh://git@github.com/zackberman/nytxw-stats";
      inputs.nixpkgs.follows       = "nixpkgs";
      inputs.pyproject-nix.follows = "pyproject-nix";
    };
  };

  outputs = { nixpkgs, home-manager, pyproject-nix, nytxw-stats, ... }@inputs:
    let
      configurationFromProfile =
        pname: profile:
          let
            pkgs        = nixpkgs.legacyPackages.${profile.system};
            nytxw-stats = inputs.nytxw-stats.packages.${profile.system};

            extraSpecialArgs = {
              inherit pkgs;
              inherit nixpkgs;
              inherit nytxw-stats;
              inherit (profile)
                system
                username
                homeDirectory
                stateVersion
                isWSL;
            };
          in
            home-manager.lib.homeManagerConfiguration {
              inherit pkgs;

              # Specify your home configuration modules here, for example,
              # the path to your home.nix.
              modules = [ ./home.nix ];

              # Optionally use extraSpecialArgs
              # to pass through arguments to home.nix
              inherit extraSpecialArgs;
            };

      profiles = {
        macos = {
          system         = "aarch64-darwin";
          username       = "zberman";
          homeDirectory  = "/Users/zberman";
          stateVersion   = "23.11";
          isWSL          = false;
        };
        wsl = {
          system         = "x86_64-linux";
          username       = "zberman";
          homeDirectory  = "/home/zberman";
          stateVersion   = "23.11";
          isWSL          = true;
        };
      };

    in
      {
        homeConfigurations =
          nixpkgs.lib.attrsets.mapAttrs
            configurationFromProfile
            profiles;
      };
}
