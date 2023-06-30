# A standalone shell definition that downloads and uses packages from `nixpkgs-esp-dev` automatically.

let
  nixpkgs-esp-dev = builtins.fetchGit {
    url = "https://github.com/mirrexagon/nixpkgs-esp-dev.git";

    # Optionally pin to a specific commit of `nixpkgs-esp-dev`.
    # rev = "<commit hash>";
  };

  pkgs = import <nixpkgs> { overlays = [ (import "${nixpkgs-esp-dev}/overlay.nix") ]; };
in
pkgs.mkShell {
  name = "esp-project";

  buildInputs = with pkgs; [
    esp-idf-full
  ];
}
