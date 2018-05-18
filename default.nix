self: super:

let
  callPackage = super.callPackage;
  callPackage_self = super.lib.callPackageWith (self // self.xorg);
in {
  esptool = callPackage ./pkgs/esptool {};

  crosstool-ng-xtensa = callPackage ./pkgs/crosstool-ng-xtensa {};
  gcc-xtensa-lx106-elf = callPackage ./pkgs/gcc-xtensa-lx106-elf {};
  gcc-xtensa-esp32-elf = callPackage ./pkgs/gcc-xtensa-esp32-elf {};
}
