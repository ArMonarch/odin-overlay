{
  description = "Pure and reproducible overlay for binary distributed odin toolchain";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # defines system that this flake supports
    systems.url = "github:nix-systems/default";

    # Powered by
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    flake-parts,
    ...
  } @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} {
      # Systems for which attributes of perSystem will be built.
      systems = import inputs.systems;

      flake = {
        overlays = import ./overlays/default.nix {};
      };

      perSystem = {
        system,
        pkgs,
        lib,
        ...
      }: {
        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;
          overlays = [self.overlays.odin-overlays self.overlays.ols-overlays];
        };

        packages = let
          odin_sources = builtins.fromJSON (builtins.readFile ./sources/odin.json);
          ols_sources = builtins.fromJSON (builtins.readFile ./sources/ols.json);

          # Drop the tags with no prebuilt binary for this system; the overlays
          # throw on those, which would break `nix flake show` / `nix flake check`.
          available = lib.filterAttrs (_: platforms: platforms ? ${system});
        in
          lib.mapAttrs' (name: _: lib.nameValuePair "odin-${lib.removePrefix "dev-" name}" pkgs.odin-bin.${name}) (available odin_sources)
          // lib.mapAttrs' (name: _: lib.nameValuePair "ols-${lib.removePrefix "dev-" name}" pkgs.ols-bin.${name}) (available ols_sources);

        formatter = pkgs.alejandra;
      };
    };
}
