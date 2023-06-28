{ pkgs ? import ../default.nix }:

pkgs.mkShell {
  name = "esp-idf-esp32s2-shell";

  buildInputs = with pkgs; [
    esp-idf-esp32s2
  ];
}
