{
  lib,
  pkgs,
  stdenv,
  makeBinaryWrapper,
  url,
  sha256,
  version,
  ...
}:
stdenv.mkDerivation {
  pname = "ols";
  inherit version;

  src = pkgs.fetchzip {
    inherit url sha256;
    stripRoot = false;
  };

  nativeBuildInputs = [makeBinaryWrapper];

  phases = ["unpackPhase" "installPhase"];
  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    mkdir -p $out/share

    [ -d $src/builtin ] && cp -R $src/builtin $out/share

    makeBinaryWrapper $(find $src -name "ols*") $out/bin/ols \
      --set OLS_BUILTIN_FOLDER "$out/share/builtin"
    makeBinaryWrapper $(find $src -name "odinfmt*") $out/bin/odinfmt

    runHook postInstall
  '';

  meta = {
    description = "The Odin programming language Language server (prebuilt binary)";
    homepage = "https://github.com/DanielGavin/ols";
    license = lib.licenses.mit;
    platforms = ["x86_64-linux" "aarch64-linux"];
    mainProgram = "ols";
  };
}
