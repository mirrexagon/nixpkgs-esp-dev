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
    pypiDataRev = "2385b06414a8406732bb8c0de86b20d17ca8c19d";
    pypiDataSha256 = "sha256:1hixh41l3f232mgwmzsljdbyvyc0sdhvl8ph5s3f8cqbw2m4yny1";
    pkgs = final;
  };
in
{
  # ESP32
  gcc-xtensa-esp32-elf-bin = prev.callPackage ./pkgs/esp32-toolchain-bin.nix { };
  openocd-esp32-bin = prev.callPackage ./pkgs/openocd-esp32-bin.nix { };

  esp-idf = prev.callPackage ./pkgs/esp-idf { inherit mach-nix; };

  # ESP8266
  gcc-xtensa-lx106-elf-bin = prev.callPackage ./pkgs/esp8266-toolchain-bin.nix { };

  # Note: These are currently broken because they fetch files during the build, making them impure which flakes don't allow.
  crosstool-ng-xtensa = prev.callPackage ./pkgs/crosstool-ng-xtensa.nix { };
  gcc-xtensa-lx106-elf = prev.callPackage ./pkgs/gcc-xtensa-lx106-elf { };
}
