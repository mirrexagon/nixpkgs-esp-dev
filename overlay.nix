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
    pypiDataRev = "1d17587404960e2e9fd0fd7e514b0bbc52abcdfd";
    pypiDataSha256 = "sha256:078i0af4s1la5cafq958wfk8as711qlf81ngrg0xq0wys7ainig1";
    pkgs = final;
  };
in
{
  # ESP32C3
  gcc-riscv32-esp32c3-elf-bin = prev.callPackage ./pkgs/esp32c3-toolchain-bin.nix { };
  # ESP32S2
  gcc-xtensa-esp32s2-elf-bin = prev.callPackage ./pkgs/esp32s2-toolchain-bin.nix { };
  # ESP32
  gcc-xtensa-esp32-elf-bin = prev.callPackage ./pkgs/esp32-toolchain-bin.nix { };
  openocd-esp32-bin = prev.callPackage ./pkgs/openocd-esp32-bin.nix { };

  esp-idf = prev.callPackage ./pkgs/esp-idf { inherit mach-nix; };

  # ESP8266
  gcc-xtensa-lx106-elf-bin = prev.callPackage ./pkgs/esp8266-toolchain-bin.nix { };

  # Note: These are currently broken in flake mode because they fetch files
  # during the build, making them impure.
  crosstool-ng-xtensa = prev.callPackage ./pkgs/crosstool-ng-xtensa.nix { };
  gcc-xtensa-lx106-elf = prev.callPackage ./pkgs/gcc-xtensa-lx106-elf { };
}
