{ pkgs }:

let
  buildsNameList = pkgs.lib.attrsets.cartesianProduct {
    target = [
      "esp32"
    ];
    example = [ [ "get-started" "hello_world" ] ];
  };

  buildsList = pkgs.lib.lists.flatten (
    builtins.map (
      spec:
      let
        # Build each of these with both esp-idf-full and the appropriate esp-idf-esp32xx.
        buildFull = pkgs.lib.attrByPath spec.example null pkgs.esp-idf-full.examples.${spec.target};
      in
      [
        (pkgs.lib.attrsets.nameValuePair buildFull.name buildFull)
      ]
    ) buildsNameList
  );
in
builtins.listToAttrs buildsList
