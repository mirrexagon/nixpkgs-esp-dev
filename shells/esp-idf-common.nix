{ pkgs ? import ../default.nix, esp-idf-package }:

pkgs.mkShell {
  name = "${esp-idf-package.pname}-shell";

  buildInputs = [ esp-idf-package ];
  
  shellHook = ''
    export IDF_PYTHON_ENV_PATH="$(python -c 'import sys; print(sys.prefix)' 2>/dev/null || echo "$IDF_PYTHON_ENV_PATH")"
    
    # Fetch ESP-IDF tags if needed (function defined in setup-hook.sh)
    fetchEspIdfTags
  '';
}
