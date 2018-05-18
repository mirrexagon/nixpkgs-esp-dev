with import <nixpkgs> {};

stdenv.mkDerivation {
  name = "esp-idf-env";

  buildInputs = [
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
