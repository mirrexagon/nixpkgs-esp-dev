{
  pkgs ? import <nixpkgs> {
    # The Python library ecdsa is marked as insecure, but we need it for esptool.
    # See https://github.com/mirrexagon/nixpkgs-esp-dev/issues/109
    config.permittedInsecurePackages = [
      "python3.13-ecdsa-0.19.1"
    ];
  },
  lib ? pkgs.lib,
}:

lib.makeScope pkgs.newScope (self: import ./overlay.nix self self)
