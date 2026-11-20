{ lib, ... }:
{
  flake.modules.homeManager.registry = {
    nix.registry =
      let
        lockfile = builtins.fromJSON (builtins.readFile ../flake.lock);
        inputs   = [ "nixpkgs" "pyproject-nix" ];

        mkIndirectFromLockfile =
          name: {
            from = {
              id   = name;
              type = "indirect";
            };
            to = lockfile.nodes.${name}.locked;
          };

      in
        lib.genAttrs inputs mkIndirectFromLockfile;
  };
}
