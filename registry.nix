args@{
  config,
  pkgs,
  ...
}:

{
  nix.registry = {
    nixpkgs = {
      from = {
        id   = "nixpkgs";
        type = "indirect";
      };
      flake = args.nixpkgs;
    };
  };
}
