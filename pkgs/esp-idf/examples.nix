{ lib, esp-idf, buildExample, target }:

let
  # Recursively convert the directory tree into a nested attribute set
  traverseDir = path: prefix:
    let
      entries = builtins.readDir path;
      # Check if any file in the directory starts with "sdkconfig"
      isLeaf = lib.any (name: lib.hasPrefix "sdkconfig" name) (builtins.attrNames entries);
      subdirs = lib.attrsets.filterAttrs (_: type: type == "directory") entries;
    in
      if isLeaf then
        (buildExample {
          target = target;
          name = "${target}-${prefix}";
          src = path;
        })
      else
        lib.attrsets.mapAttrs (name: _: traverseDir "${path}/${name}" 
          (if prefix == "" then name else "${prefix}-${name}")) subdirs;
in

# Call traverseDir on your root path
traverseDir "${esp-idf}/examples" ""