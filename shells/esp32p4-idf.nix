{
  pkgs ? import <nixpkgs> {
    overlays = [ (import ../overlay.nix) ];

    # The Python library ecdsa is marked as insecure, but we need it for esptool.
    # See https://github.com/mirrexagon/nixpkgs-esp-dev/issues/109
    config.permittedInsecurePackages = [
      "python3.13-ecdsa-0.19.1"
    ];
  },
}:

builtins.warn
  "[DEPRECATION WARNING] Chip specific shell will be removed starting ESP-IDF 6.0. Use esp-idf-full instead."

  pkgs.mkShell
  {
    name = "esp-idf-esp32p4-shell";

    buildInputs = with pkgs; [
      esp-idf-esp32p4
    ];
  }
