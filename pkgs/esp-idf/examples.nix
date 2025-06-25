{ lib, esp-idf, buildExample }:

let
  # Recursively convert the directory tree into a nested attribute set
  traverseDir = path:
    let
      entries = builtins.readDir path;
      isLeaf = builtins.hasAttr "sdkconfig.defaults" entries;
      subdirs = lib.attrsets.filterAttrs (_: type: type == "directory") entries;
    in
      if isLeaf then
        (buildExample {
          target = "esp32c6";
          example = path;
        })
      else
        lib.attrsets.mapAttrs (name: _: traverseDir "${path}/${name}") subdirs;
in

# Call traverseDir on your root path
traverseDir "${esp-idf}/examples"