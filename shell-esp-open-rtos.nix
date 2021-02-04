{ pkgs ? import ./default.nix }:

pkgs.stdenv.mkDerivation {
  name = "esp-open-rtos-env";
  buildInputs = with pkgs; [
    (python37.withPackages (ppkgs: with ppkgs; [ pyserial ]))
    gcc-xtensa-lx106-elf
    esptool
  ];
  shellHook = ''
  '';
}
