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

    mkdir -p $out/bin $out/share

    [ -d $src/builtin ] && cp -R $src/builtin $out/share

    # The server binary is named "ols" in recent releases and
    # "ols-<target-triple>" in older ones.
    olsBin=$(find $src -type f -name "ols*" | head -n1)
    makeBinaryWrapper "$olsBin" $out/bin/ols \
      --set OLS_BUILTIN_FOLDER "$out/share/builtin"

    # odinfmt is only bundled with newer releases.
    odinfmtBin=$(find $src -type f -name "odinfmt*" | head -n1)
    if [ -n "$odinfmtBin" ]; then
      makeBinaryWrapper "$odinfmtBin" $out/bin/odinfmt
    fi

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
