{
  lib,
  clang,
  stdenvNoCC,
  makeBinaryWrapper,
  version,
  url,
  sha256,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "odin";
  inherit version;

  src = builtins.fetchTarball {
    inherit url sha256;
  };

  nativeBuildInputs = [makeBinaryWrapper];

  phases = ["unpackPhase" "installPhase"];
  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    mkdir -p $out/share

    cp -r {base,core,shared,vendor} $out/share

    makeBinaryWrapper $src/odin $out/bin/odin \
      --set ODIN_ROOT "$out/share" \
      --prefix PATH : "${lib.makeBinPath [clang]}"

    runHook postInstall
  '';

  meta = {
    description = "The Odin programming language (prebuilt binary)";
    homepage = "https://odin-lang.org";
    license = lib.licenses.bsd3;
    platforms = ["x86_64-linux" "aarch64-linux"];
    mainProgram = "odin";
  };
}
