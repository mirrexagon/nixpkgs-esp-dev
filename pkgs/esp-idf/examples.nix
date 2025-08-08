{ lib, esp-idf, buildExample, target }:

let
  # Recursively convert the directory tree into a nested attribute set
  traverseDir = path: prefix:
    let
      entries = builtins.readDir path;
      # Check if any file in the directory starts with "sdkconfig"
      isLeaf = lib.any (name: lib.hasPrefix "sdkconfig" name) (lib.attrNames entries);
      # Filter to only include directories
      subdirs = lib.filterAttrs (_: type: type == "directory") entries;
    in
      if isLeaf then
        # This is a leaf node (an actual example project)
        (buildExample {
          inherit target;
          name = "${target}-${prefix}";
          src = path;
        })
      else
        # Continue traversing subdirectories
        lib.mapAttrs 
          (name: _: traverseDir "${path}/${name}" 
            (if prefix == "" then name else "${prefix}-${name}")) 
          subdirs;
in
traverseDir "${esp-idf}/examples" ""