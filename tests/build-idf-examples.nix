{ pkgs }:

let
  build-idf-example =
    { target, example, esp-idf, suffix }:

    (pkgs.stdenv.mkDerivation {
      name = "test-build-${target}-${builtins.replaceStrings [ "/" ] [ "-" ] example}-${suffix}";

      buildInputs = [
        esp-idf
      ];

      phases = [ "buildPhase" ];

      buildPhase = ''
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
      '';
    });

  buildsNameList = pkgs.lib.attrsets.cartesianProduct {
    target = [ "esp32" "esp32c3" "esp32s2" "esp32s3" "esp32c6" "esp32h2" ];
    example = [ "get-started/hello_world" ];
  };

  buildsList = pkgs.lib.lists.flatten (builtins.map
    (spec:
      let
        # Build each of these with both esp-idf-full and the appropriate esp-idf-esp32xx.
        buildFull = build-idf-example (spec // { esp-idf = pkgs.esp-idf-full; suffix = "full"; });
        buildSpecific = build-idf-example (spec // { esp-idf = pkgs."esp-idf-${spec.target}"; suffix = "specific"; });
      in
      [
        (pkgs.lib.attrsets.nameValuePair buildFull.name buildFull)
        (pkgs.lib.attrsets.nameValuePair buildSpecific.name buildSpecific)
      ])
    buildsNameList);
in
builtins.listToAttrs buildsList
