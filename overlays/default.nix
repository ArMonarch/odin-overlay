{...}: {
  odin-overlay = final: prev: let
    mkOdin = prev.callPackage ../lib/mkOdin.nix;
    sources = builtins.fromJSON (builtins.readFile ../sources/odin.json);
    system = prev.stdenv.hostPlatform.system;

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
    odin-bin = allVersions;
  };

  ols-overlay = final: prev: let
    mkOLS = prev.callPackage ../lib/mkOLS.nix;
    sources = builtins.fromJSON (builtins.readFile ../sources/ols.json);
    system = prev.stdenv.hostPlatform.system;

    allVersions =
      builtins.mapAttrs (
        version: platforms:
          if builtins.hasAttr system platforms
          then {
            latest =
              mkOLS
              {
                inherit version;
                inherit (platforms.${system}) name url sha256;
              };
          }
          else throw "ols-bin.${version}: no prebuilt binary for ${system}"
      )
      sources;
  in {
    ols-bin = allVersions;
  };
}
