{ pkgs ? import ../default.nix }:

pkgs.mkShell {
  name = "esp8266";

  buildInputs = with pkgs; [
    gcc-xtensa-lx106-elf-bin
    esptool
  ];
}
