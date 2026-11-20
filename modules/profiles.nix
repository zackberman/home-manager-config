{ config, inputs, ... }:

let
  inherit (inputs) home-manager nixpkgs;
  homeModules = config.flake.modules.homeManager;

  configurationFromProfile = _: { system, homeDirectory, isWSL }:
    let
      pkgs = nixpkgs.legacyPackages.${system};
    in
    home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [
        {
          imports = [
            homeModules.packages
            ../programs
            homeModules.registry
            homeModules.home
          ];

          home = {
            username = "zberman";
            inherit homeDirectory;

            # Keep the compatibility version for this existing home.
            stateVersion = "23.11";
          };
        }
      ];

      extraSpecialArgs = { inherit homeDirectory isWSL pkgs; };
    };
in
{
  flake.homeConfigurations = nixpkgs.lib.mapAttrs configurationFromProfile {
    macos = {
      system = "aarch64-darwin";
      homeDirectory = "/Users/zberman";
      isWSL = false;
    };
    wsl = {
      system = "x86_64-linux";
      homeDirectory = "/home/zberman";
      isWSL = true;
    };
  };
}
