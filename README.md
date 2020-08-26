# nixpkgs-esp-dev
Derivations for developing for ESP8266 and ESP32 on NixOS.

This repo contains derivations for:
- Toolchains (compiler, linker, etc.) for `xtensa-lx106-elf` and `xtensa-esp32-elf` built with the xtensa fork of [crosstool-NG](https://github.com/jcmvbkbc/crosstool-NG)
- The xtensa crosstool-NG fork itself.
- [esptool](https://github.com/espressif/esptool)

The easiest way to get started is to use `nix-shell` with one of these:
- `shell-esp32.nix`: for ESP32 development with [esp-idf](https://github.com/espressif/esp-idf)
- `shell-esp-open-rtos.nix`: for ESP8266 development with [esp-open-rtos](https://github.com/SuperHouse/esp-open-rtos)

To add this as a nixpkgs overlay, clone this repo somewhere on your machine and symlink `overlay.nix` to a file in `~/.config/nixpkgs/overlays`, eg. `~/.config/nixpkgs/overlays/esp-dev.nix`.

---

Note: This currently is impure and requires sandboxing to be turned off in Nix. On NixOS, set `nix.useSandbox = false;` in your NixOS configuration.

---

Partly adapted from [esp-open-sdk](https://github.com/pfalcon/esp-open-sdk).

Released into the public domain via CC0 (see `COPYING`).
