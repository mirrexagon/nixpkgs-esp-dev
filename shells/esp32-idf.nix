{ pkgs ? import ../default.nix }:

pkgs.mkShell {
  name = "esp-idf";

  buildInputs = with pkgs; [
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
