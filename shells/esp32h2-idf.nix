{ pkgs ? import ../default.nix }:

builtins.warn "[DEPRECATION WARNING] Chip specific shell will be removed starting ESP-IDF 6.0. Use esp-idf-full instead."

pkgs.mkShell {
  name = "esp-idf-esp32h2-shell";

  buildInputs = with pkgs; [
    esp-idf-esp32h2
  ];
}
