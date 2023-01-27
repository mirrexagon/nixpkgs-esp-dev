# nixpkgs-esp-dev
ESP8266 and ESP32(-C3, -S2, -S3) packages and development environments for Nix.

This repo contains derivations for:
- Toolchains (compiler, linker, GDB, etc.) for `xtensa-lx106-elf` (ESP8266) and `xtensa-esp32-elf` (ESP32) using the official binaries from Espressif.
- [ESP-IDF](https://github.com/espressif/esp-idf)
- [OpenOCD for ESP32](https://github.com/espressif/openocd-esp32)

Released into the public domain via CC0 (see `COPYING`).


## Getting started
### `nix develop`
The easiest way to get started is to run one of these commands to get a development shell, without even needing to download the repository (requires Nix 2.4 or later):

- `nix --experimental-features 'nix-command flakes' develop github:mirrexagon/nixpkgs-esp-dev#esp32-idf`: for ESP32 development with [esp-idf](https://github.com/espressif/esp-idf).
    - Includes the ESP32 toolchain, esptool, the OpenOCD fork supporting ESP32, and downloads and sets up ESP-IDF with everything ready to use `idf.py`.
- `nix --experimental-features 'nix-command flakes' develop github:mirrexagon/nixpkgs-esp-dev#esp8266`: for ESP8266 development with eg. [esp-open-rtos](https://github.com/SuperHouse/esp-open-rtos)
    - Includes the ESP8266 toolchain and esptool.

### `nix-shell`
If you're not using Nix 2.4+ or prefer not to need to enable flakes, you can clone the repo and use one of:

- `nix-shell shells/esp32c3-idf.nix`
- `nix-shell shells/esp32s2-idf.nix`
- `nix-shell shells/esp32s3-idf.nix`
- `nix-shell shells/esp32-idf.nix`
- `nix-shell shells/esp8266.nix`

to get the same shells as with `nix develop`.

Note: `nix develop` will use the nixpkgs revision specified in `flake.nix`/`flake.lock`, while using `nix-shell` will use your system nixpkgs by default.


## Creating a custom shell environment
You can create a standalone `shell.nix` for your project that downloads `nixpkgs-esp-dev` automatically and creates a shell with the necessary packages and environment setup to use ESP-IDF.

See `examples/shell-standalone.nix` for an example.


## Overriding ESP-IDF and ESP32 toolchain versions
There are default versions of ESP-IDF and the ESP32 toolchain versions specified in `pkgs/esp32-toolchain-bin.nix` and `pkgs/esp-idf/default.nix`. To use a different version of ESP-IDF or to pin the versions, override the derivations with the desired versions and the hashes for them. Note that given versions of ESP-IDF require specific versions of the toolchain, which is why the versions of both are customizable.

See `examples/shell-override-versions.nix` for an example.


## Overlay
This repo contains an overlay in `overlay.nix` containing all the packages defined by this repo. If you clone the repo into `~/.config/nixpkgs/overlays/`, nixpkgs will automatically pick up the overlay and effectively add the packages to your system nixpkgs.
