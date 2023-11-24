{
  description = "Home Manager configuration of zberman";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }:
    let
      configurationFromProfile =
        pname: profile:
          let
            pkgs = nixpkgs.legacyPackages.${profile.system};

            extraSpecialArgs = {
              inherit pkgs;
              inherit (profile)
                system
                username
                homeDirectory
                stateVersion; };
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
          stateVersion   = "23.05";
        };
        wsl = {
          system         = "x86_64-linux";
          username       = "zberman";
          homeDirectory  = "/home/zberman";
          stateVersion   = "23.05";
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
