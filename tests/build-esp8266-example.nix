{ pkgs }:

let
  build-esp8266-example =
    { example }:

    (pkgs.stdenv.mkDerivation {
      name = "test-build-esp8266-${builtins.replaceStrings [ "/" ] [ "-" ] example}";

      buildInputs = with pkgs; [ esp8266-rtos-sdk ];

      phases = [ "buildPhase" ];

      buildPhase = ''
        cp -r $IDF_PATH/examples/${example}/* .
        chmod -R +w .

        # The build system wants to create a cache directory somewhere in the home
        # directory, so we make up a home for it.
        mkdir temp-home
        export HOME=$(readlink -f temp-home)

        idf.py build

        mkdir $out
        cp -r * $out
      '';
    });

  examplesToBuild = [ "get-started/hello_world" ];

  buildsList = builtins.map (
    example:
    let
      build = build-esp8266-example { inherit example; };
    in
    pkgs.lib.attrsets.nameValuePair build.name build
  ) examplesToBuild;
in
builtins.listToAttrs buildsList
