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

    # Locate the toolchain root by finding the `odin` binary. Releases place it
    # either at the top level (plain tarball) or under a versioned subdirectory
    # (the .zip releases, which wrap a dist.tar.gz).
    odinExe=$(find . -type f -name odin -print -quit)
    root=$(dirname "$odinExe")

    mkdir -p $out/bin $out/libexec $out/share

    cp -r "$root"/{base,core,shared,vendor} $out/share
    install -Dm755 "$odinExe" $out/libexec/odin

    # macOS releases bundle libLLVM/libzstd in a `libs` directory and reference
    # them as @executable_path/libs/*, so they have to sit next to the installed
    # binary. Linux releases have no such directory.
    if [ -d "$root/libs" ]; then
      cp -r "$root"/libs $out/libexec/libs
    fi

    makeBinaryWrapper $out/libexec/odin $out/bin/odin \
      --set ODIN_ROOT "$out/share" \
      --prefix PATH : "${lib.makeBinPath [clang]}"

    runHook postInstall
  '';

  meta = {
    description = "The Odin programming language (prebuilt binary)";
    homepage = "https://odin-lang.org";
    license = lib.licenses.bsd3;
    platforms = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
    mainProgram = "odin";
  };
}
