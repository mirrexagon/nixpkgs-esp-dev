{
  version ? "1.94.0.2",
  url ? "https://github.com/esp-rs/rust-build/releases/download/v${version}/rust-src-${version}.tar.xz",
  hash ? "sha256-A8J1ScXW8c39Tw/6KKYsC6+XnCgkGewSGnfxttKxz4c=",

  lib,
  stdenv,
  fetchurl,
  zlib,
}:
stdenv.mkDerivation rec {
  pname = "esp-rust-src";
  inherit version;

  src = fetchurl {
    inherit url hash;
  };

  installPhase = ''
    patchShebangs install.sh
    CFG_DISABLE_LDCONFIG=1 ./install.sh --prefix=$out

    rm $out/lib/rustlib/{components,install.log,manifest-*,rust-installer-version,uninstall.sh} || true
  '';
  dontStrip = true;
}
