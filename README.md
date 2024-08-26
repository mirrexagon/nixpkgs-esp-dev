# nixpkgs-esp-dev
ESP8266 and ESP32(-C3, -S2, -S3, -C6, -H2) packages and development environments for Nix.

This repo contains derivations for ESP-IDF, and most of the toolchains and tools it depends on (compilers for all supported targets, custom OpenOCD for Espressif chips, etc.).

Released into the public domain via CC0 (see `COPYING`).


## Getting started
### `nix develop`
The easiest way to get started is to run one of these commands to get a development shell, without even needing to download the repository (requires Nix 2.4 or later):

- `nix --experimental-features 'nix-command flakes' develop github:mirrexagon/nixpkgs-esp-dev#esp32-idf`: for ESP32 development with [esp-idf](https://github.com/espressif/esp-idf).
    - Includes the ESP32 toolchain, and downloads and sets up ESP-IDF with everything ready to use `idf.py`.
- `nix --experimental-features 'nix-command flakes' develop github:mirrexagon/nixpkgs-esp-dev#esp8266-rtos-sdk`: for ESP8266 development with [ESP8266_RTOS_SDK](https://github.com/espressif/ESP8266_RTOS_SDK).
    - Includes the ESP8266 toolchain, ESP8266_RTOS_SDK, and esptool.

The list of available shells (to go after the `#` in the command) are:

- `esp-idf-full`: Includes toolchains for _all_ supported ESP32 chips (no ESP8266).
- `esp32-idf`: Includes toolchain for the ESP32.
- `esp32c3-idf`: Includes toolchain for the ESP32-C3.
- `esp32s2-idf`: Includes toolchain for the ESP32-S2.
- `esp32s3-idf`: Includes toolchain for the ESP32-S3.
- `esp32c6-idf`: Includes toolchain for the ESP32-C6.
- `esp32h2-idf`: Includes toolchain for the ESP32-H2.
- `esp8266-rtos-sdk`: Includes toolchain for ESP8266 and esptool.

### `nix-shell`
If you're not using Nix 2.4+ or prefer not to need to enable flakes, you can clone the repo and use one of:

- `nix-shell shells/esp32-idf-full.nix`
- `nix-shell shells/esp32-idf.nix`
- `nix-shell shells/esp32c3-idf.nix`
- `nix-shell shells/esp32s2-idf.nix`
- `nix-shell shells/esp32s3-idf.nix`
- `nix-shell shells/esp32c6-idf.nix`
- `nix-shell shells/esp32h2-idf.nix`
- `nix-shell shells/esp8266-rtos-sdk.nix`

to get the same shells as with `nix develop`.

Note: `nix develop` will use the nixpkgs revision specified in `flake.nix`/`flake.lock`, while using `nix-shell` will use your system nixpkgs by default.


## Creating a custom shell environment
You can create a standalone `shell.nix` for your project that downloads `nixpkgs-esp-dev` automatically and creates a shell with the necessary packages and environment setup to use ESP-IDF.

See `examples/shell-standalone.nix` for an example.


## Overriding ESP-IDF and ESP32 toolchain versions
There is a default version of ESP-IDF specified in `pkgs/esp-idf/default.nix`. To use a different version of ESP-IDF or to pin the version, override a `esp-idf-*` derivations with the desired version and the hash for it. The correct version of the tools will be downloaded automatically.

NOTE: This doesn't quite work as it should - Python packages won't be adapted for the version you override to. See https://github.com/mirrexagon/nixpkgs-esp-dev/issues/25

See `examples/shell-override-versions.nix` for an example.


## Overlay
This repo contains an overlay in `overlay.nix` containing all the packages defined by this repo. If you clone the repo into `~/.config/nixpkgs/overlays/`, nixpkgs will automatically pick up the overlay and effectively add the packages to your system nixpkgs.
