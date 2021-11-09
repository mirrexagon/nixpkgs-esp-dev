{ rev ? "v4.3.1"
, sha256 ? "sha256-+SMdnIBSCdHy+MDbInl/aXJuXOf9seJbQ3u4mN+qFP4="
, stdenv
, lib
, fetchFromGitHub
, mach-nix
, python3
}:

let
  src = fetchFromGitHub {
    owner = "espressif";
    repo = "esp-idf";
    rev = rev;
    sha256 = sha256;
    fetchSubmodules = true;
  };

  pythonEnv =
    let
      # Comment out Windows-specific line from requirements.txt that mach-nix can't parse.
      requirementsOriginalText = builtins.readFile "${src}/requirements.txt";
      requirementsText = builtins.replaceStrings
        [ "file://" ]
        [ "#file://" ]
        requirementsOriginalText;
    in
    # https://github.com/DavHau/mach-nix/issues/153#issuecomment-775102329
    mach-nix.mkPython
      {
        requirements = requirementsText;
      };
in
stdenv.mkDerivation rec {
  pname = "esp-idf";
  version = rev;

  inherit src;

  # This is so that downstream derivations will have IDF_PATH set.
  setupHook = ./setup-hook.sh;

  propagatedBuildInputs = [
    # This is so that downstream derivations will run the Python setup hook and get PYTHONPATH set up correctly.
    # TODO: Ensures this uses the same python derivation as mach-nix, or have it use this one.
    python3
  ];

  installPhase = ''
    mkdir -p $out
    cp -r $src/* $out/

    # Link the Python environment in so that in shell derivations, the Python
    # setup hook will add the site-packages directory to PYTHONPATH.
    ln -s ${pythonEnv}/lib $out/
  '';
}
