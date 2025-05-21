{ pkgs ? import ../default.nix }:

pkgs.mkShell {
  name = "esp-idf-esp32c5-shell";

  buildInputs = with pkgs; [
    esp-idf-esp32c5
  ];
}
