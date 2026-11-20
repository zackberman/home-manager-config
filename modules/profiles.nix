{ inputs, ... }:

let
  inherit (inputs) home-manager nixpkgs;

  configurationFromProfile = _: profile:
    let
      pkgs = nixpkgs.legacyPackages.${profile.system};
    in
    home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [ ../home.nix ];
      extraSpecialArgs = {
        inherit nixpkgs pkgs;
        nytxw-stats = inputs.nytxw-stats.packages.${profile.system};
        inherit (profile) system username homeDirectory stateVersion isWSL;
      };
    };

  profiles = {
    macos = {
      system = "aarch64-darwin";
      username = "zberman";
      homeDirectory = "/Users/zberman";
      stateVersion = "23.11";
      isWSL = false;
    };
    wsl = {
      system = "x86_64-linux";
      username = "zberman";
      homeDirectory = "/home/zberman";
      stateVersion = "23.11";
      isWSL = true;
    };
  };
in
{
  flake.homeConfigurations = nixpkgs.lib.mapAttrs configurationFromProfile profiles;
}
