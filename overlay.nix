final: prev: rec {
  esp-idf-full = prev.callPackage ./pkgs/esp-idf { };

  esp-idf-xtensa = esp-idf-full.override {
    toolsToInclude = [
      "xtensa-esp-elf"
      "esp32ulp-elf"
      "openocd-esp32"
      "xtensa-esp-elf-gdb"
      "esp-rom-elfs"
    ];
  };

  esp-idf-riscv = esp-idf-full.override {
    toolsToInclude = [
      "riscv32-esp-elf"
      "openocd-esp32"
      "riscv32-esp-elf-gdb"
      "esp-rom-elfs"
    ];
  };

  esp-idf-esp32 = esp-idf-xtensa;
  esp-idf-esp32s2 = esp-idf-xtensa;
  esp-idf-esp32s3 = esp-idf-xtensa;
  esp-idf-esp32c2 = esp-idf-riscv;
  esp-idf-esp32c3 = esp-idf-riscv;
  esp-idf-esp32c5 = esp-idf-riscv;
  esp-idf-esp32c6 = esp-idf-riscv;
  esp-idf-esp32h2 = esp-idf-riscv;
  esp-idf-esp32p4 = esp-idf-riscv;

  # ESP8266
  gcc-xtensa-lx106-elf-bin = prev.callPackage ./pkgs/esp8266/gcc-xtensa-lx106-elf-bin.nix { };
  esp8266-rtos-sdk = prev.callPackage ./pkgs/esp8266/esp8266-rtos-sdk/esp8266-rtos-sdk.nix { };
  esp8266-nonos-sdk = prev.callPackage ./pkgs/esp8266/esp8266-nonos-sdk/esp8266-nonos-sdk.nix { };

  # QEMU
  qemu-esp32 = prev.callPackage ./pkgs/qemu-esp32 { };
}
