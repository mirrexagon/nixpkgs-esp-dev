{ pkgs ? import ../default.nix }:

pkgs.mkShell {
  name = "esp-idf-esp32-shell";

  buildInputs = with pkgs; [
    esp-idf-esp32
  ];

  shellHook = ''
    export IDF_PYTHON_ENV_PATH="$(python -c 'import sys; print(sys.prefix)' 2>/dev/null || echo "$IDF_PYTHON_ENV_PATH")"
  '';
}
