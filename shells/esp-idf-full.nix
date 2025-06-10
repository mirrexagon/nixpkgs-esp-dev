{
  pkgs ? import ../default.nix,
}:

pkgs.mkShell {
  name = "esp-idf-full-shell";

  buildInputs = with pkgs; [ esp-idf-full ];
}
