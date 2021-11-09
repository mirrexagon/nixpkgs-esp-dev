# A standalone shell definition that overrides the versions of ESP-IDF and the ESP32 toolchain.

let
  nixpkgs-esp-dev = builtins.fetchGit {
    url = "https://github.com/mirrexagon/nixpkgs-esp-dev.git";
  };

  pkgs = import <nixpkgs> { overlays = [ (import "${nixpkgs-esp-dev}/overlay.nix") ]; };
in
pkgs.mkShell
{
  name = "esp-project";

  buildInputs = with pkgs; [
    (gcc-xtensa-esp32-elf-bin.override {
      version = "2021r2";
      hash = "sha256-PrPWiyf6a6Wvb4jaIcuPrOm+AJTaqolgeTz+Vwq3hf8=";
    })

    (esp-idf.override {
      rev = "f5a2fc578d586b28f5f270787524132e99d94741";
      sha256 = "sha256-ldbHXWPWkYQCWJiY0v8phgtFQnBu7eSObp3j5+nV8L4=";
    })

    # Tools required to use ESP-IDF.
    git
    wget
    gnumake

    flex
    bison
    gperf
    pkgconfig

    cmake
    ninja

    ncurses5
  ];
}
