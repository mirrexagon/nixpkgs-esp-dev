{ pkgs ? import ../default.nix }:

import ./esp-idf-common.nix { inherit pkgs; esp-idf-package = pkgs.esp-idf-esp32c5; }
