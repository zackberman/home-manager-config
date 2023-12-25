args@{
  config,
  pkgs,
  ...
}:

{
  nix.registry =
    let
      lockfile = builtins.fromJSON (builtins.readFile ./flake.lock);
      locked   = lockfile.nodes.nixpkgs.locked;

    in {
      nixpkgs = {
        from = {
          id   = "nixpkgs";
          type = "indirect";
        };
        to = locked;
      };
    };
}
