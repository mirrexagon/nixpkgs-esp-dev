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

pkgs.mkShell {
  name = "esp8266-nonos-sdk-shell";

  buildInputs = with pkgs; [
    esp8266-nonos-sdk
  ];
}
