{
  lib,
  stdenv,
  unzip,
  makeBinaryWrapper,
  url,
  sha256,
  version,
  ...
}:
stdenv.mkDerivation {
  pname = "ols";
  inherit version;

  src = builtins.fetchurl {
    inherit url sha256;
  };

  nativeBuildInputs = [unzip makeBinaryWrapper];

  phases = ["unpackPhase" "installPhase"];

  unpackPhase = ''
    runHook preUnpack
    unzip $src -d $out
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    mkdir -p $out/share

    [ -d $out/builtin ] && mv $out/builtin $out/share

    mv $(find $out -name "odinfmt*") $out/bin
    mv $(find $out -name "ols*") $out/bin


    makeBinaryWrapper $(find $out -name "ols*") $out/bin/ols \
      --set OLS_BUILTIN_FOLDER "$out/share/builtin"
    makeBinaryWrapper $(find $out -name "odinfmt*") $out/bin/odinfmt

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
