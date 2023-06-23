final: prev:
let
  # mach-nix is used to set up the ESP-IDF Python environment.
  mach-nix-src = prev.fetchFromGitHub {
    owner = "DavHau";
    repo = "mach-nix";
    rev = "98d001727542bb6142d0ab554fc30bd591b07c73";
    hash = "sha256-SXrwF/KPz8McBN8kN+HTfGphE1hiRSr1mtXSVjPJr8o=";
  };

  mach-nix = import mach-nix-src {
    pypiDataRev = "3ea10df4be564e619cb1c34922822c6e8ad74ea7";
    pypiDataSha256 = "sha256:02w7qr70gxcq99abjk7ql49ffkvbmd3phwzv2pgiqvjkcgsnxdzj";
    pkgs = final;
  };
in
{
  # ESP32
  gcc-xtensa-esp32-elf-bin = prev.callPackage ./pkgs/esp32-toolchain-bin.nix { };
  esp32ulp-elf-bin = prev.callPackage ./pkgs/esp32-ulp-toolchain-bin.nix { };

  # ESP32-C3
  gcc-riscv32-esp32c3-elf-bin = prev.callPackage ./pkgs/esp32c3-toolchain-bin.nix { };

  # ESP32-S2
  gcc-xtensa-esp32s2-elf-bin = prev.callPackage ./pkgs/esp32s2-toolchain-bin.nix { };

  # ESP32-S3
  gcc-xtensa-esp32s3-elf-bin = prev.callPackage ./pkgs/esp32s3-toolchain-bin.nix { };

  openocd-esp32-bin = prev.callPackage ./pkgs/openocd-esp32-bin.nix { };

  esp-idf = prev.callPackage ./pkgs/esp-idf { inherit mach-nix; };

  # ESP8266
  gcc-xtensa-lx106-elf-bin = prev.callPackage ./pkgs/esp8266-toolchain-bin.nix { };

  # Note: These are currently broken in flake mode because they fetch files
  # during the build, making them impure.
  crosstool-ng-xtensa = prev.callPackage ./pkgs/crosstool-ng-xtensa.nix { };
  gcc-xtensa-lx106-elf = prev.callPackage ./pkgs/gcc-xtensa-lx106-elf { };
}
