{
  description = "ESP8266/ESP32 development tools";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    mach-nix = {
      url = "github:DavHau/mach-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.pypi-deps-db.url = "github:DavHau/pypi-deps-db/2385b06414a8406732bb8c0de86b20d17ca8c19d";
    };
  };

  outputs = { self, nixpkgs, flake-utils, mach-nix }: {
    overlay = final: prev: {
      # ESP32
      gcc-xtensa-esp32-elf-bin = prev.callPackage ./pkgs/esp32-toolchain-bin.nix { };
      openocd-esp32-bin = prev.callPackage ./pkgs/openocd-esp32-bin.nix { };

      esp-idf = prev.callPackage ./pkgs/esp-idf { inherit mach-nix; };

      # ESP8266
      gcc-xtensa-lx106-elf-bin = prev.callPackage ./pkgs/esp8266-toolchain-bin.nix { };

      # Note: These are currently broken because they fetch files during the build, making them impure which flakes don't allow.
      crosstool-ng-xtensa = prev.callPackage ./pkgs/crosstool-ng-xtensa.nix { };
      gcc-xtensa-lx106-elf = prev.callPackage ./pkgs/gcc-xtensa-lx106-elf { };
    };
  } // flake-utils.lib.eachSystem [ "x86_64-linux" ] (system:
    let
      pkgs = import nixpkgs { inherit system; overlays = [ self.overlay ]; };
    in
    {
      packages = {
        inherit (pkgs)
          gcc-xtensa-esp32-elf-bin
          openocd-esp32-bin
          esp-idf

          gcc-xtensa-lx106-elf-bin
          crosstool-ng-xtensa
          gcc-xtensa-lx106-elf;
      };

      devShells = {
        esp32-idf = pkgs.callPackage ./shells/esp32-idf.nix { };
        esp8266 = pkgs.callPackage ./shells/esp8266.nix { };
      };
    });
}

