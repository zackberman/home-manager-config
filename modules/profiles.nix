{ config, inputs, ... }:

let
  inherit (inputs) home-manager nixpkgs;
  homeModules = config.flake.modules.homeManager;

  configurationFromProfile = _: { system, homeDirectory, isWSL, enableKarabiner }:
    home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.${system};
      modules = [
        {
          imports = [
            homeModules.packages
            homeModules.programs
            homeModules.registry
            homeModules.home
          ];

          _module.args = { inherit isWSL; };
          programs.karabiner.enable = enableKarabiner;

          home = {
            username = "zberman";
            inherit homeDirectory;

            # Keep the compatibility version for this existing home.
            stateVersion = "23.11";
          };
        }
      ];
    };
in
{
  flake.homeConfigurations = nixpkgs.lib.mapAttrs configurationFromProfile {
    macos = {
      system = "aarch64-darwin";
      homeDirectory = "/Users/zberman";
      isWSL = false;
      enableKarabiner = true;
    };
    wsl = {
      system = "x86_64-linux";
      homeDirectory = "/home/zberman";
      isWSL = true;
      enableKarabiner = false;
    };
  };
}
