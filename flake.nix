{
  description = "ESP8266/ESP32 development tools";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    {
      overlays.default = import ./overlay.nix;
    }
    // flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ self.overlays.default ];
          config.permittedInsecurePackages = [
            "python3.13-ecdsa-0.19.1"
          ];
        };
      in
      {
        packages = {
          inherit (pkgs)
            esp-idf-full
            esp-idf-riscv
            esp-idf-xtensa
            esp-idf-esp32
            esp-idf-esp32c2
            esp-idf-esp32c3
            esp-idf-esp32s2
            esp-idf-esp32s3
            esp-idf-esp32c6
            esp-idf-esp32h2
            esp-idf-esp32p4
            gcc-xtensa-lx106-elf-bin
            # esp8266-rtos-sdk # Broken
            esp8266-nonos-sdk
            esp-rustc
            esp-rustc-src
            ;
        };

        devShells = rec {
          default = esp-idf-full;
          esp-idf-full = import ./shells/esp-idf-full.nix { inherit pkgs; };
          esp32-idf = import ./shells/esp32-idf.nix { inherit pkgs; };
          esp32c2-idf = import ./shells/esp32c2-idf.nix { inherit pkgs; };
          esp32c3-idf = import ./shells/esp32c3-idf.nix { inherit pkgs; };
          esp32s2-idf = import ./shells/esp32s2-idf.nix { inherit pkgs; };
          esp32s3-idf = import ./shells/esp32s3-idf.nix { inherit pkgs; };
          esp32c6-idf = import ./shells/esp32c6-idf.nix { inherit pkgs; };
          esp32h2-idf = import ./shells/esp32h2-idf.nix { inherit pkgs; };
          esp32p4-idf = import ./shells/esp32p4-idf.nix { inherit pkgs; };
          # esp8266-rtos-sdk = import ./shells/esp8266-rtos-sdk.nix { inherit pkgs; }; # Broken
          esp8266-nonos-sdk = import ./shells/esp8266-nonos-sdk.nix { inherit pkgs; };
        };

        checks =
          (import ./tests/build-idf-examples.nix { inherit pkgs; });
          # For now, the esp8266-rtos-sdk is broken upstream (https://github.com/mirrexagon/nixpkgs-esp-dev/issues/94).
          # // (import ./tests/build-esp8266-example.nix { inherit pkgs; });
      }
    );
}
