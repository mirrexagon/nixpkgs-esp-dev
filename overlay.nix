final: prev:
let
  # mach-nix is used to set up the ESP-IDF Python environment.
  mach-nix-src = prev.fetchFromGitHub {
    owner = "DavHau";
    repo = "mach-nix";
    rev = "refs/tags/3.4.0";
    hash = "sha256-CJDg/RpZdUVyI3QIAXUqIoYDl7VkxFtNE4JWih0ucKc=";
  };

  mach-nix = import mach-nix-src {
    pypiDataRev = "f1b18354f73e8805de32e635be0fe86c9fb8eb84";
    pypiDataSha256 = "sha256:0vmia5hlv31v99krdkp83kyg1aa76jh8896wa3cafh9q0hsry40q";
    pkgs = final;
  };
in
{
  # ESP32C3
  gcc-riscv32-esp32c3-elf-bin = prev.callPackage ./pkgs/esp32c3-toolchain-bin.nix { };
  gcc-riscv32-esp32s2-elf-bin = prev.callPackage ./pkgs/esp32s2-toolchain-bin.nix { };
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
