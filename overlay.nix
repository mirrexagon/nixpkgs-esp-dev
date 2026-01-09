final: prev: let
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

  esp-rustc = prev.callPackage ./pkgs/rustc { };
  esp-rustc-src = prev.callPackage ./pkgs/rustc/src.nix { };

  mkDeprecatedAlias = arch: name: alias: {
    "${name}" = builtins.warn ''
        [DEPRECATION WARNING] `${name}` is deprecated and will be removed starting with ESP-IDF 6.0.
        Please use `esp-idf-full` or `esp-idf-${arch}` instead.

        More information here : https://github.com/mirrexagon/nixpkgs-esp-dev/issues/91
      '' alias;
  };

  deprecatedAlias = builtins.foldl' (acc: pair: acc // (mkDeprecatedAlias pair.arch pair.name pair.alias)) {} [
    { name = "esp-idf-esp32"; alias = esp-idf-xtensa; arch = "xtensa"; }
    { name = "esp-idf-esp32s2"; alias = esp-idf-xtensa; arch = "xtensa"; }
    { name = "esp-idf-esp32s3"; alias = esp-idf-xtensa; arch = "xtensa"; }
    { name = "esp-idf-esp32c2"; alias = esp-idf-riscv;  arch = "riscv"; }
    { name = "esp-idf-esp32c3"; alias = esp-idf-riscv;  arch = "riscv"; }
    { name = "esp-idf-esp32c6"; alias = esp-idf-riscv;  arch = "riscv"; }
    { name = "esp-idf-esp32h2"; alias = esp-idf-riscv;  arch = "riscv"; }
    { name = "esp-idf-esp32p4"; alias = esp-idf-riscv;  arch = "riscv"; }
  ];
in deprecatedAlias // {
  inherit esp-idf-full esp-idf-xtensa esp-idf-riscv esp-rustc esp-rustc-src;

  # ESP8266
  gcc-xtensa-lx106-elf-bin = prev.callPackage ./pkgs/esp8266/gcc-xtensa-lx106-elf-bin.nix { };
  esp8266-rtos-sdk = prev.callPackage ./pkgs/esp8266/esp8266-rtos-sdk/esp8266-rtos-sdk.nix { };
  esp8266-nonos-sdk = prev.callPackage ./pkgs/esp8266/esp8266-nonos-sdk/esp8266-nonos-sdk.nix { };

  # QEMU
  qemu-esp32 = prev.callPackage ./pkgs/qemu-esp32 { };
}
