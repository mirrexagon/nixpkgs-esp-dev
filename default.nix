# Returns nixpkgs with the overlay from this repo applied.
import <nixpkgs> { overlays = [ (import ./overlay.nix) ]; }
