{ toolSpecList # The `tools` entry in `tools/tools.json` in an ESP-IDF checkout.
, versionSuffix # A string to use in the version of the tool derivations.

, stdenv
, lib
, fetchurl
, makeBinaryWrapper
, autoPatchelfHook

  # Dependencies for the various binary tools.
, zlib
, libusb1
, udev
, glibc
, ncurses5
, python3
, libxml2_13
}:

let
  required-python-version = "3.9";
  ESP-IDF-version = lib.removePrefix "esp-idf-" versionSuffix;
in
assert lib.assertMsg (lib.versionAtLeast python3.version required-python-version)
  "ESP-IDF ${ESP-IDF-version} requires Python ≧${required-python-version}";

let
  # Map nix system strings to the platforms listed in tools.json
  systemToToolPlatformString = {
    "x86_64-linux" = "linux-amd64";
    "aarch64-linux" = "linux-arm64";
    "x86_64-darwin" = "macos";
    "aarch64-darwin" = "macos-arm64";
  };

  # Common runtime dependencies for ELF binaries
  commonRuntimeDeps = [
    glibc
    stdenv.cc.cc.lib
    zlib
    ncurses5
    libusb1
    udev
    python3
    libxml2_13
  ];

  toolSpecToDerivation = toolSpec:
    let
      targetPlatform = systemToToolPlatformString.${stdenv.hostPlatform.system};
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
      runtimeDeps = commonRuntimeDeps;
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
    , runtimeDeps
    , exportVars
    , stripContainerDirs
    , exportPaths
    }:

    let
      binPaths = map (path: lib.foldl' (a: b: if a == "" then b else "${a}/${b}") "" path) exportPaths;
      exportVarsWrapperArgsList = lib.attrsets.mapAttrsToList (name: value: "--set \"${name}\" \"${value}\"") exportVars;
    in stdenv.mkDerivation (finalAttrs: {
      inherit pname version;

      src = fetchurl {
        inherit url sha256;
      };

      nativeBuildInputs = [ makeBinaryWrapper ] ++ lib.optionals stdenv.isLinux [ autoPatchelfHook ];
      buildInputs = lib.optionals stdenv.isLinux runtimeDeps;

      phases = [ "unpackPhase" "installPhase" ] ++ lib.optionals stdenv.isLinux [ "fixupPhase" ];

      setSourceRoot = ''sourceRoot=$(echo ./${lib.strings.replicate stripContainerDirs "*/"})'';

      # Expose binPaths as an array
      __structuredAttrs = true;

      inherit binPaths;

      noDumpEnvVars = true;

      dontStrip = true;

      installPhase = ''
        python_lib="$(find "${lib.getLib python3}/lib" -maxdepth 1 -name 'libpython*.so.*' -type f | head -n1)"
        so_name="$(patchelf --print-soname "$python_lib")"
        export so_name

        cp -r . $out
        rm $out/.attrs.*

        # For setting exported variables (see exportVarsWrapperArgsList).
        TOOL_PATH=$out

        for bindir in "''${binPaths[@]}"; do
          if [ "$bindir" = "bin" ]; then
            mv $out/bin $out/unwrapped_bin
            bindir=unwrapped_bin
          fi
          if [ -d "$out/$bindir" ]; then
            for file in $(find "$out/$bindir" -type f -executable -maxdepth 1); do
              libpython_so=$(patchelf --print-needed "$file" | grep -e "^libpython" || true)
              if [ -n "$libpython_so" ] && [ "$libpython_so" != "$so_name" ]; then
                echo "Removing $file" >&2
                rm "$file"
                continue
              fi
              wrapper_file="$out/bin/$(basename "$file")"
              [ -d "$out/bin" ] || mkdir -p "$out/bin"
              makeBinaryWrapper "$file" "$wrapper_file" ${lib.strings.concatStringsSep " " exportVarsWrapperArgsList}
            done
          fi
        done

        # for clangd to find the system headers
        libdir=''${bindir%/bin}/lib
        if [ -d $out/$libdir ]; then
          ln -s $libdir $out/lib
        fi
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
