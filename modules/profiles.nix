{ config, inputs, ... }:

let
  inherit (inputs) home-manager nixpkgs;
  homeModules = config.flake.modules.homeManager;

  configurationFromProfile = _: {
    system,
    homeDirectory,
    isWSL,
    enableKarabiner,
    remapFunctionRow ? true,
  }:
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
          programs.karabiner = {
            enable = enableKarabiner;
            inherit remapFunctionRow;
          };

          home = {
            username = "zberman";
            inherit homeDirectory;

            # Keep the compatibility version for this existing home.
            stateVersion = "23.11";
          };
        }
      ];
    };

  macos = {
    system = "aarch64-darwin";
    homeDirectory = "/Users/zberman";
    isWSL = false;
    enableKarabiner = true;
  };
in
{
  flake.homeConfigurations = nixpkgs.lib.mapAttrs configurationFromProfile {
    studio = macos;
    air = macos // { remapFunctionRow = false; };
    wsl = {
      system = "x86_64-linux";
      homeDirectory = "/home/zberman";
      isWSL = true;
      enableKarabiner = false;
    };
  };
}
