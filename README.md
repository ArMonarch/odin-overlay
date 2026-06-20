# odin-overlay

Pure and reproducible Nix overlay for the binary-distributed [Odin](https://odin-lang.org)
toolchain and the [OLS](https://github.com/DanielGavin/ols) language server.

Instead of compiling Odin from source, this overlay fetches the official
prebuilt release artifacts and wraps them so they work on NixOS (correct
`ODIN_ROOT`, `clang` on `PATH`, `OLS_BUILTIN_FOLDER`, etc.).

## What it provides

Two overlays, each adding a versioned package set indexed by the upstream
release tag:

- `odin-bin.<tag>.latest` — the Odin compiler (e.g. `odin-bin."dev-2026-06".latest`)
- `ols-bin.<tag>.latest` — the OLS language server (e.g. `ols-bin."dev-2026-05".latest`)

Available tags are listed in [`sources/odin.json`](sources/odin.json) and
[`sources/ols.json`](sources/ols.json).

| Component | Systems |
| --------- | ------- |
| Odin      | `x86_64-linux`, `aarch64-linux` |
| OLS       | `x86_64-linux` |

## Usage

### As a flake (default packages)

```sh
# Latest pinned Odin compiler
nix run github:ArMonarch/odin-overlay#odin -- version

# Latest pinned OLS language server
nix build github:ArMonarch/odin-overlay#ols
```

### As an overlay in your own flake

```nix
{
  inputs.odin-overlay.url = "github:ArMonarch/odin-overlay";

  outputs = {nixpkgs, odin-overlay, ...}: let
    pkgs = import nixpkgs {
      system = "x86_64-linux";
      overlays = [
        odin-overlay.overlays.odin-overlay
        odin-overlay.overlays.ols-overlay
      ];
    };
  in {
    devShells.x86_64-linux.default = pkgs.mkShell {
      packages = [
        pkgs.odin-bin."dev-2026-06".latest
        pkgs.ols-bin."dev-2026-05".latest
      ];
    };
  };
}
```

## Updating sources

Each entry in `sources/*.json` pins a release URL and its Nix hash.

- **Odin** is consumed with `builtins.fetchTarball` (which strips the archive's
  leading directory), so its `sha256` is the *base32 NAR hash* of the unpacked,
  root-stripped tree.
- **OLS** is consumed with `fetchzip { stripRoot = false; }`, so its `sha256` is
  the *base64 SRI hash* of the unpacked tree (matching `nix-prefetch-url --unpack`
  converted to base64).

To compute a new Odin hash:

```sh
nix eval --impure --raw --expr 'builtins.fetchTarball {
  url = "<release-url>";
  sha256 = "0000000000000000000000000000000000000000000000000000";
}'
# read the real value from the reported "got: sha256:..." mismatch
```

To compute a new OLS hash:

```sh
b32=$(nix-prefetch-url --unpack "<release-url>")
nix hash convert --hash-algo sha256 --to base64 "$b32"
```
