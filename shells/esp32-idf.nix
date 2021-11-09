{ mkShell
, stdenv
, lib
, fetchFromGitHub
, gcc-xtensa-esp32-elf-bin
, openocd-esp32-bin
, esptool
, esp-idf
, git
, wget
, gnumake
, flex
, bison
, gperf
, pkgconfig
, cmake
, ninja
, ncurses5
}:

mkShell {
  name = "esp-idf";

  buildInputs = [
    gcc-xtensa-esp32-elf-bin
    openocd-esp32-bin
    esp-idf
    esptool

    git
    wget
    gnumake

    flex
    bison
    gperf
    pkgconfig

    cmake
    ninja

    ncurses5
  ];
}
