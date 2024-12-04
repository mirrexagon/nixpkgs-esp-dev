{ toolSpecList # The `tools` entry in `tools/tools.json` in an ESP-IDF checkout.
, versionSuffix # A string to use in the version of the tool derivations.
, toolFhsEnvTargetPackages ? { # Extra dependencies for particular tools
  esp-clang = pkgs: (with pkgs; [ zlib libxml2 ]);
  openocd-esp32 = pkgs: (with pkgs; [ zlib libusb1 udev ]);
}

, stdenv
, system
, lib
, fetchurl
, buildFHSUserEnv
, makeWrapper

  # Dependencies for the various binary tools.
, zlib
, libusb1
, udev
}:

let
  # Map nix system strings to the platforms listed in tools.json
  systemToToolPlatformString = {
    "x86_64-linux" = "linux-amd64";
    "aarch64-linux" = "linux-arm64";
    "x86_64-darwin" = "macos";
    "aarch64-darwin" = "macos-arm64";
  };

  toolSpecToDerivation = toolSpec:
    let
      targetPlatform = systemToToolPlatformString.${system};
      targetVersionSpecs = builtins.elemAt toolSpec.versions 0;
      targetVersionSpec = targetVersionSpecs.${targetPlatform} or targetVersionSpecs.any;
      platformOverrides = builtins.filter (o: lib.elem targetPlatform o.platforms) (toolSpec.platform_overrides or []);
      mergedToolSpec = lib.foldl' lib.recursiveUpdate toolSpec platformOverrides;
    in
    mkToolDerivation {
      pname = mergedToolSpec.name;

      # NOTE: tools.json does not separately specify the versions of tools,
      # so short of extracting the versions from the tarball URLs, we will
      # just put the ESP-IDF version as the tool version.
      version = versionSuffix;

      description = mergedToolSpec.description;
      homepage = mergedToolSpec.info_url;
      license = { spdxId = mergedToolSpec.license; };
      url = targetVersionSpec.url;
      sha256 = targetVersionSpec.sha256;
      targetPkgs = toolFhsEnvTargetPackages."${mergedToolSpec.name}" or (_: []);
      exportVars = mergedToolSpec.export_vars;
      # strip_container_dirs specifies the number of parent directories to remove
      stripContainerDirs = mergedToolSpec.strip_container_dirs or 0;
      # export_paths specifies the directories that contain binaries
      # When there are not binaries to export, a path is specified as [""].
      exportPaths = builtins.filter (path: path != [""]) (mergedToolSpec.export_paths or []);
    };

  mkToolDerivation =
    { pname
    , version
    , description
    , homepage
    , license
    , url
    , sha256
    , targetPkgs
    , exportVars
    , stripContainerDirs
    , exportPaths
    }:

    let
      fhsEnv = buildFHSUserEnv {
        name = "${pname}-env";
        inherit targetPkgs;
        runScript = "";
      };

      binPaths = map (path: lib.foldl' (a: b: if a == "" then b else "${a}/${b}") "" path) exportPaths;

      exportVarsWrapperArgsList = lib.attrsets.mapAttrsToList (name: value: "--set \"${name}\" \"${value}\"") exportVars;
    in stdenv.mkDerivation (finalAttrs: {
      inherit pname version;

      src = fetchurl {
        inherit url sha256;
      };

      buildInputs = [ makeWrapper ];

      phases = [ "unpackPhase" "installPhase" ];

      setSourceRoot = ''sourceRoot=$(echo ./${lib.strings.replicate stripContainerDirs "*/"})'';

      # Expose binPaths as an array
      __structuredAttrs = true;

      inherit binPaths;

      noDumpEnvVars = true;

      installPhase = let
        wrapCmd = if (system == "x86_64-linux") || (system == "aarch64-linux") then
          ''
          makeWrapper ${fhsEnv}/bin/${pname}-env "$wrapper_file" --add-flags "$file" ${lib.strings.concatStringsSep " " exportVarsWrapperArgsList}
        ''
      else
      ''
        if [ -n "${lib.strings.concatStringsSep " " exportVarsWrapperArgsList}" ]; then
          makeWrapper "$file" "$wrapper_file" ${lib.strings.concatStringsSep " " exportVarsWrapperArgsList}
        else
          ln -s "$file" "$wrapper_file"
        fi
      '';
      in ''
        cp -r . $out
        rm $out/.attrs.*

        # For setting exported variables (see exportVarsWrapperArgsList).
        TOOL_PATH=$out

        for bindir in "''${binPaths[@]}"; do
          if [ "$bindir" = "bin" ]; then
            mv $out/bin $out/unwrapped_bin
            bindir=unwrapped_bin
          fi
          for file in $out/$bindir/*; do
            wrapper_file="$out/bin/$(basename "$file")"
            [ -d "$out/bin" ] || mkdir "$out/bin"
            ${wrapCmd}
          done
        done
      '';

      meta = with lib; {
        inherit description homepage license;
      };

      passthru = let
        inherit (finalAttrs.finalPackage) outPath;
      in {
        exportVars = lib.mapAttrs (_: v: lib.replaceStrings ["\${TOOL_PATH}" "$TOOL_PATH"] [outPath outPath] v) exportVars;
      };
    });

in
builtins.listToAttrs (builtins.map (toolSpec: lib.attrsets.nameValuePair toolSpec.name (toolSpecToDerivation toolSpec)) toolSpecList)
