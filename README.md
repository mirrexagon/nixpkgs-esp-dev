# nixpkgs-esp-dev
nixpkgs overlay with derivations for developing for ESP8266 and ESP32.

This overlay contains derivations for: 
- Toolchains (compiler, linker, etc.) for `xtensa-lx106-elf` and `xtensa-esp32-elf` built with the xtensa fork of [crosstool-NG](https://github.com/espressif/crosstool-NG)
- The xtensa crosstool-NG fork itself.
- [esptool](https://github.com/espressif/esptool)
 
There is also a derivation (`shell-esp32.nix`) for use with `nix-shell`, for ESP32 development with [esp-idf](https://github.com/espressif/esp-idf).

Partly adapted from [esp-open-sdk](https://github.com/pfalcon/esp-open-sdk).

Released into the public domain via CC0 (see `COPYING`).

