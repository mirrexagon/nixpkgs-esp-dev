{ mkShell, gcc-xtensa-lx106-elf-bin, esptool }:

mkShell {
  name = "esp8266";

  buildInputs = [
    gcc-xtensa-lx106-elf-bin
    esptool
  ];
}
