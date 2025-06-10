{
  pkgs ? import ../default.nix,
}:

pkgs.mkShell {
  name = "esp-idf-esp32p4-shell";

  buildInputs = with pkgs; [ esp-idf-esp32p4 ];
}
