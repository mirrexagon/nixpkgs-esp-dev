{
  pkgs ? import ../default.nix,
}:

pkgs.mkShell {
  name = "esp-idf-esp32h2-shell";

  buildInputs = with pkgs; [ esp-idf-esp32h2 ];
}
