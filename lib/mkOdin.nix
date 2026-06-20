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

    # Some older .zip releases wrap everything in a single dist.tar.gz.
    [ -f dist.tar.gz ] && tar -xzf dist.tar.gz

    # Locate the toolchain root by finding the `odin` binary. Releases variously
    # place it at the top level (plain tarball), under a versioned subdirectory,
    # or next to a __MACOSX metadata directory.
    odinExe=$(find . -type f -name odin -not -path '*/__MACOSX/*' -print -quit)
    root=$(dirname "$odinExe")

    mkdir -p $out/bin $out/libexec $out/share

    cp -r "$root"/{base,core,shared,vendor} $out/share
    install -Dm755 "$odinExe" $out/libexec/odin

    makeBinaryWrapper $out/libexec/odin $out/bin/odin \
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
