# nixpkgs-esp-dev
Derivations for developing for ESP8266 and ESP32 on NixOS.

**NOTE:** This repo builds the toolchains from source, which takes a while. If you are doing ESP32 development, I recommend adapting https://nixos.wiki/wiki/ESP-IDF instead of using this.

This repo contains derivations for:
- Toolchains (compiler, linker, etc.) for `xtensa-lx106-elf` and `xtensa-esp32-elf` built with the xtensa fork of [crosstool-NG](https://github.com/jcmvbkbc/crosstool-NG)
- The xtensa crosstool-NG fork itself.
- [esptool](https://github.com/espressif/esptool)

The easiest way to get started is to use `nix-shell` with one of these:
- `shell-esp32.nix`: for ESP32 development with [esp-idf](https://github.com/espressif/esp-idf)
- `shell-esp-open-rtos.nix`: for ESP8266 development with [esp-open-rtos](https://github.com/SuperHouse/esp-open-rtos)

To add this as a nixpkgs overlay, clone this repo somewhere on your machine and symlink `overlay.nix` to a file in `~/.config/nixpkgs/overlays`, eg. `~/.config/nixpkgs/overlays/esp-dev.nix`.

---

Note: This currently is impure and requires sandboxing to be turned off. Run commands that build things from this repo with `--option sandbox false`.

---

Partly adapted from [esp-open-sdk](https://github.com/pfalcon/esp-open-sdk).

Released into the public domain via CC0 (see `COPYING`).
