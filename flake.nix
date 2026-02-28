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
    pkgs = import nixpkgs {
      system = "x86_64-linux";
      overlays = [self.overlays.odin-overlay];
    };
  in {
    overlays = import ./overlays/default.nix {
      inherit self;
      inherit (nixpkgs) lib;
    };

    packages."x86_64-linux".odin = pkgs.odin-bin."dev-2026-02".latest;
  };
}
