{ pkgs }:

with pkgs.lib;

let
  buildsNameList = pkgs.lib.attrsets.cartesianProduct {
    target = [
      "esp32"
      "esp32s2"
      "esp32s3"
      "esp32c2"
      "esp32c3"
      "esp32c6"
      "esp32h2"
      "esp32p4"
    ];
    example = [ [ "get-started" "hello_world" ] ];
  };

  buildsList = pkgs.lib.lists.flatten (
    builtins.map (
      spec:
      let
        # Build each of these with both esp-idf-full and the appropriate esp-idf-esp32xx.
        buildFull = attrByPath spec.example null pkgs.esp-idf-full.examples.${spec.target};
        buildSpecific = attrByPath spec.example null pkgs."esp-idf-${spec.target}".examples.${spec.target};
      in
      [
        (pkgs.lib.attrsets.nameValuePair buildFull.name buildFull)
        (pkgs.lib.attrsets.nameValuePair buildSpecific.name buildSpecific)
      ]
    ) buildsNameList
  );
in
builtins.listToAttrs buildsList
