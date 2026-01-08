# A standalone shell definition that overrides the versions of ESP-IDF and the ESP32 toolchain.

let
  nixpkgs-esp-dev = builtins.fetchGit {
    url = "https://github.com/mirrexagon/nixpkgs-esp-dev.git";
  };

  pkgs = import <nixpkgs> {
    overlays = [ (import "${nixpkgs-esp-dev}/overlay.nix") ];

    # The Python library ecdsa is marked as insecure, but we need it for esptool.
    # See https://github.com/mirrexagon/nixpkgs-esp-dev/issues/109
    config.permittedInsecurePackages = [
      "python3.13-ecdsa-0.19.1"
    ];
  };
in
pkgs.mkShell {
  name = "esp-project";

  buildInputs = with pkgs; [
    (esp-idf-esp32.override {
      rev = "cf7e743a9b2e5fd2520be4ad047c8584188d54da";
      sha256 = "sha256-tqWUTJlOWk4ayfQIxgiLkTrrTFU0ZXuh76xEZWKRZ/s=";
    })
  ];
}
