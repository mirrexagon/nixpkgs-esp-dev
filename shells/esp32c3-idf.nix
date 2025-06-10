{
  pkgs ? import ../default.nix,
}:

pkgs.mkShell {
  name = "esp-idf-esp32c3-shell";

  buildInputs = with pkgs; [ esp-idf-esp32c3 ];
}
