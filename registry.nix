args@{
  config,
  pkgs,
  ...
}:

{
  nix.registry =
    let
      lockfile = builtins.fromJSON (builtins.readFile ./flake.lock);
      inputs   = [ "nixpkgs" "poetry2nix" ];

      mkIndirectFromLockfile =
        name: {
          from = {
            id   = name;
            type = "indirect";
          };
          to = lockfile.nodes.${name}.locked;
        };

    in
      pkgs.lib.genAttrs inputs mkIndirectFromLockfile;
}
