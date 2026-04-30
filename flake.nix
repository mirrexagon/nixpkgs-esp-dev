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
            gcc-xtensa-lx106-elf-bin
            # esp8266-rtos-sdk # Broken
            esp8266-nonos-sdk
            ;
        };

        devShells = rec {
          default = esp-idf-full;
          esp-idf-full = import ./shells/esp-idf-full.nix { inherit pkgs; };
          esp-idf-riscv = import ./shells/esp-idf-riscv.nix { inherit pkgs; };
          esp-idf-xtensa = import ./shells/esp-idf-xtensa.nix { inherit pkgs; };
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
