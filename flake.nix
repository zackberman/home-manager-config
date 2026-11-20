{
  description = "Home Manager configuration of zberman";

  inputs = {
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    import-tree.url = "github:denful/import-tree";

    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url          = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
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

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);
}
