{
  lib,
  stdenv,
  makeBinaryWrapper,
  fetchzip,
  url,
  sha256,
  version,
  ...
}:
stdenv.mkDerivation {
  pname = "ols";
  inherit version;

  src = fetchzip {
    inherit url sha256;
    stripRoot = false;
  };

  nativeBuildInputs = [makeBinaryWrapper];

  phases = ["unpackPhase" "installPhase"];
  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/libexec $out/share

    [ -d $src/builtin ] && cp -R $src/builtin $out/share

    # The server binary is named "ols" in recent releases and
    # "ols-<target-triple>" in older ones.
    olsExe=$(find $src -type f -name "ols*" | head -n1)
    install -Dm755 "$olsExe" $out/libexec/ols

    # Should a release ever bundle dylibs next to the binaries (as the macOS Odin
    # releases do), they have to sit beside $out/libexec for the
    # @executable_path/libs/* lookups to resolve. No OLS release ships one today.
    if [ -d "$src/libs" ]; then
      cp -r "$src"/libs $out/libexec/libs
    fi

    makeBinaryWrapper $out/libexec/ols $out/bin/ols \
      --set OLS_BUILTIN_FOLDER "$out/share/builtin"

    # odinfmt is only bundled with newer releases.
    odinfmtExe=$(find $src -type f -name "odinfmt*" | head -n1)
    if [ -n "$odinfmtExe" ]; then
      install -Dm755 "$odinfmtExe" $out/libexec/odinfmt
      makeBinaryWrapper $out/libexec/odinfmt $out/bin/odinfmt
    fi

    runHook postInstall
  '';

  meta = {
    description = "The Odin programming language Language server (prebuilt binary)";
    homepage = "https://github.com/DanielGavin/ols";
    license = lib.licenses.mit;
    platforms = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
    mainProgram = "ols";
  };
}
