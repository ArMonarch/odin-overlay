{
  description = "Pure and reproducible overlay for binary distributed odin toolchain";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = {
    self,
    nixpkgs,
    ...
  }: let
    # Odin ships prebuilt binaries for both x86_64-linux and aarch64-linux;
    # OLS sources here cover x86_64-linux only, so its package is exposed for
    # that system below.
    pkgsFor = system:
      import nixpkgs {
        inherit system;
        overlays = [self.overlays.odin-overlay self.overlays.ols-overlay];
      };

    # Latest pinned releases used for the default package outputs.
    odinLatest = "dev-2026-06";
    olsLatest = "dev-2026-05";
  in {
    overlays = import ./overlays/default.nix {
      inherit self;
      inherit (nixpkgs) lib;
    };

    packages = {
      x86_64-linux = let
        pkgs = pkgsFor "x86_64-linux";
      in {
        odin = pkgs.odin-bin.${odinLatest}.latest;
        ols = pkgs.ols-bin.${olsLatest}.latest;
        default = pkgs.odin-bin.${odinLatest}.latest;
      };

      aarch64-linux = let
        pkgs = pkgsFor "aarch64-linux";
      in {
        odin = pkgs.odin-bin.${odinLatest}.latest;
        default = pkgs.odin-bin.${odinLatest}.latest;
      };
    };
  };
}
