{ pkgs ? import ./default.nix {} }:

pkgs.stdenv.mkDerivation {
  name = "esp-idf-env";

  buildInputs = with pkgs; [
    gcc-xtensa-esp32-elf

    git
    wget
    gnumake

    flex
    bison
    gperf
    pkgconfig

    ncurses

    python27Packages.python
    python27Packages.pyserial
  ];
}
