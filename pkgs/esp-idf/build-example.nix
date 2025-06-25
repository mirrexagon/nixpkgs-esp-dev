{ stdenv, esp-idf, jq, writeShellApplication }:

{ target, example }: let

  flash = writeShellApplication {
    name = "flash";
    text = ''
      set -e
      
      # Default to the current directory if no argument is provided
      SCRIPT_DIR="$(dirname "$(readlink -f "''${BASH_SOURCE[0]}")")"
      cd "$SCRIPT_DIR/../build"

      eval "$(
        jq -r '.extra_esptool_args | to_entries | map("\(.key)=\(.value|@sh)") | .[]' "flasher_args.json"
      )"

      stubarg=""
      if [ "$stub" = "false" ]; then
        stubarg="--no-stub"
      fi

      ${esp-idf}/python-env/bin/python3 -m esptool "$@" --chip "$chip" --before "$before" --after "$after" $stubarg write_flash "@flash_args"
    '';

    checkPhase = "";

    runtimeInputs = [
      esp-idf
      jq
    ];
  };

in

stdenv.mkDerivation {
    name = "${target}-${builtins.replaceStrings [ "/" ] [ "-" ] example}";

    buildInputs = [
      esp-idf
    ];

    phases = [ "buildPhase" ];

    buildPhase = ''
    set -x

    cp -r $IDF_PATH/examples/${example}/* .
    chmod -R +w .

    # The build system wants to create a cache directory somewhere in the home
    # directory, so we make up a home for it.
    mkdir temp-home
    export HOME=$(readlink -f temp-home)

    # idf-component-manager wants to access the network, so we disable it.
    export IDF_COMPONENT_MANAGER=0

    idf.py set-target ${target}
    idf.py build

    mkdir $out
    cp -r * $out

    mkdir $out/bin
    cp ${flash}/bin/flash $out/bin/
    '';
}

