{self, ...}: {
  odin-overlay = final: prev: let
    mkOdin = prev.callPackage ../lib/mkOdin.nix;
    sources = builtins.fromJSON (builtins.readFile ../sources/odin.json);
    system = prev.stdenv.hostPlatform.system;

    latest = let
      version = builtins.head (builtins.attrNames sources);
      url = sources.${version}.${system}.url;
      sha256 = sources.${version}.${system}.sha256;
    in
      mkOdin {
        inherit version url sha256;
      };

    allVersions =
      builtins.mapAttrs (
        version: platforms:
          if builtins.hasAttr system platforms
          then {
            latest =
              mkOdin
              {
                inherit version;
                inherit (platforms.${system}) url sha256;
              };
          }
          else throw "odin-bin.${version}: no prebuilt binary for ${system}"
      )
      sources;
  in {
    odin-bin = {inherit latest;} // allVersions;
  };

  default = self.overlays.odin-overlay;
}
