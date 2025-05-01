{
  pkgs ? import <nixpkgs> { },
  lib ? pkgs.lib,
}:

lib.makeScope pkgs.newScope (self: import ./overlay.nix self self)
