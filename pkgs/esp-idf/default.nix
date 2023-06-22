# When updating to a newer version, check if the version of `esp32-toolchain-bin.nix` also needs to be updated.
{ rev ? "v5.0.2"
, sha256 ? "sha256-dlmtTjoz4qQdFG229v9bIHKpYBzjM44fv+XhdDBu2Os="
, stdenv
, lib
, fetchFromGitHub
, mach-nix
, makeWrapper
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
      # Remove things from requirements.txt that aren't necessary and mach-nix can't parse:
      # - Comment out Windows-specific "file://" line.
      # - Comment out ARMv7-specific "--only-binary" line.
      requirementsOriginalText = builtins.readFile "${src}/tools/requirements/requirements.core.txt";
      requirementsText = builtins.replaceStrings
        [ "file://" "--only-binary" ]
        [ "#file://" "#--only-binary" ]
        requirementsOriginalText;
    in
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

  nativeBuildInputs = [ makeWrapper ];

  propagatedBuildInputs = [
    # This is so that downstream derivations will run the Python setup hook and get PYTHONPATH set up correctly.
    pythonEnv.python
  ];

  installPhase = ''
    mkdir -p $out
    cp -rv . $out/

    wrapProgram $out/tools/idf.py --set IDF_PYTHON_ENV_PATH ${pythonEnv} --set IDF_PYTHON_CHECK_CONSTRAINTS no

    # Link the Python environment in so that in shell derivations, the Python
    # setup hook will add the site-packages directory to PYTHONPATH.
    ln -s ${pythonEnv}/lib $out/
  '';
}
