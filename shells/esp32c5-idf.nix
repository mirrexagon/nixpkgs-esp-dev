{ pkgs ? import ../default.nix }:

pkgs.mkShell {
  name = "esp-idf-esp32c5-shell";

  shellHook = ''
    # Fix git dubious ownership for ESP-IDF
    git config --global --add safe.directory "$IDF_PATH" 2>/dev/null || true
  '';

  buildInputs = with pkgs; [
    ( esp-idf-esp32c5.override { rev = "d930a386dae"; } )
  ];
}
