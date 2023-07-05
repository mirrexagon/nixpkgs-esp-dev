{
  description = "ESP8266/ESP32 development tools";

  inputs = {
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }: {
    overlays.default = import ./overlay.nix;
  } // flake-utils.lib.eachSystem [ "x86_64-linux" ] (system:
    let
      pkgs = import nixpkgs { inherit system; overlays = [ self.overlays.default ]; };
    in
    {
      packages = {
        inherit (pkgs)
          esp-idf-full
          esp-idf-esp32c3
          esp-idf-esp32s2
          esp-idf-esp32s3
          esp-idf-esp32c6
          esp-idf-esp32h2
          gcc-xtensa-lx106-elf-bin
          esp8266-rtos-sdk;
      };

      devShells = {
        esp-idf-full = import ./shells/esp-idf-full.nix { inherit pkgs; };
        esp32-idf = import ./shells/esp32-idf.nix { inherit pkgs; };
        esp32c3-idf = import ./shells/esp32c3-idf.nix { inherit pkgs; };
        esp32s2-idf = import ./shells/esp32s2-idf.nix { inherit pkgs; };
        esp32s3-idf = import ./shells/esp32s3-idf.nix { inherit pkgs; };
        esp32c6-idf = import ./shells/esp32c6-idf.nix { inherit pkgs; };
        esp32h2-idf = import ./shells/esp32h2-idf.nix { inherit pkgs; };
        esp8266-rtos-sdk = import ./shells/esp8266-rtos-sdk.nix { inherit pkgs; };
      };

      checks = (import ./tests/build-idf-examples.nix { inherit pkgs; }) // (import ./tests/build-esp8266-example.nix { inherit pkgs; });
    });
}

