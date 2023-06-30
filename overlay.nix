final: prev:
rec {
  esp-idf-full = prev.callPackage ./pkgs/esp-idf { };

  esp-idf-esp32 = esp-idf-full.override {
    toolsToInclude = [
      "xtensa-esp32-elf"
      "esp32ulp-elf"
      "openocd-esp32"
      "xtensa-esp-elf-gdb"
    ];
  };

  esp-idf-esp32c3 = esp-idf-full.override {
    toolsToInclude = [
      "riscv32-esp-elf"
      "openocd-esp32"
      "riscv32-esp-elf-gdb"
    ];
  };

  esp-idf-esp32s2 = esp-idf-full.override {
    toolsToInclude = [
      "xtensa-esp32s2-elf"
      "esp32ulp-elf"
      "openocd-esp32"
      "xtensa-esp-elf-gdb"
    ];
  };

  esp-idf-esp32s3 = esp-idf-full.override {
    toolsToInclude = [
      "xtensa-esp32s3-elf"
      "esp32ulp-elf"
      "openocd-esp32"
      "xtensa-esp-elf-gdb"
    ];
  };

  # ESP8266
  gcc-xtensa-lx106-elf-bin = prev.callPackage ./pkgs/esp8266-toolchain-bin.nix { };

  # Note: These are currently broken in flake mode because they fetch files
  # during the build, making them impure.
  crosstool-ng-xtensa = prev.callPackage ./pkgs/crosstool-ng-xtensa.nix { };
  gcc-xtensa-lx106-elf = prev.callPackage ./pkgs/gcc-xtensa-lx106-elf { };
}
