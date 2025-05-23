{ pkgs ? import ../default.nix }:

let
  esp-idf-custom = pkgs.esp-idf-esp32c5.override { rev = "d930a386dae"; };
in
pkgs.mkShell {
  name = "esp-idf-esp32c5-shell";

  shellHook = ''
    # Fix git dubious ownership for ESP-IDF
    # When you use \${d} in a Nix string, it automatically converts derivation (d, the build recipe) 
    # into its output path (where it gets installed in /nix/store/).
    git config --global --add safe.directory "${esp-idf-custom}" 2>/dev/null || true
  '';

  buildInputs = [ esp-idf-custom ];
}
