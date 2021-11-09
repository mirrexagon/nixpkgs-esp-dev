# nixpkgs-esp-dev
A Nix flake with packages and shells for ESP8266 and ESP32 development.

This repo contains derivations for:
- Toolchains (compiler, linker, GDB, etc.) for `xtensa-lx106-elf` (ESP8266) and `xtensa-esp32-elf` (ESP32) using the official binaries from Espressif.
- ESP-IDF

The easiest way to get started is to run one of these commands to get a development shell, without even needing to download the repository (requires Nix 2.4 or later):
- `nix --experimental-features 'nix-command flakes' develop github:mirrexagon/nixpkgs-esp-dev#esp32-idf`: for ESP32 development with [esp-idf](https://github.com/espressif/esp-idf).
    - Includes the ESP32 toolchain, esptool, the OpenOCD fork supporting ESP32, and downloads and sets up ESP-IDF with everything ready to use `idf.py`.
- `nix --experimental-features 'nix-command flakes' develop github:mirrexagon/nixpkgs-esp-dev#esp8266`: for ESP8266 development with eg. [esp-open-rtos](https://github.com/SuperHouse/esp-open-rtos)
    - Includes the ESP8266 toolchain and esptool.

Partly adapted from [esp-open-sdk](https://github.com/pfalcon/esp-open-sdk).

Released into the public domain via CC0 (see `COPYING`).

## Future nice features
- As a user, specify versions of ESP-IDF and toolchain instead of using the hardcoded ones in `pkgs/esp32-toolchain-bin.nix` and `pkgs/esp-idf/default.nix` - note that specific versions of ESP-IDF require specific versions of the toolchain.
