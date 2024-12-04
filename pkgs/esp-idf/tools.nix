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
    in
    mkToolDerivation {
      pname = toolSpec.name;

      # NOTE: tools.json does not separately specify the versions of tools,
      # so short of extracting the versions from the tarball URLs, we will
      # just put the ESP-IDF version as the tool version.
      version = versionSuffix;

      description = toolSpec.description;
      homepage = toolSpec.info_url;
      license = { spdxId = toolSpec.license; };
      url = targetVersionSpec.url;
      sha256 = targetVersionSpec.sha256;
      targetPkgs = toolFhsEnvTargetPackages."${toolSpec.name}" or (_: []);
      exportVars = toolSpec.export_vars;
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
    }:

    let
      fhsEnv = buildFHSUserEnv {
        name = "${pname}-env";
        inherit targetPkgs;
        runScript = "";
      };

      exportVarsWrapperArgsList = lib.attrsets.mapAttrsToList (name: value: "--set \"${name}\" \"${value}\"") exportVars;
    in

    stdenv.mkDerivation rec {
      inherit pname version;

      src = fetchurl {
        inherit url sha256;
      };

      buildInputs = [ makeWrapper ];

      phases = [ "unpackPhase" "installPhase" ];

      installPhase = let
        wrapCmd = if (system == "x86_64-linux") || (system == "aarch64-linux") then
        ''
          [ ! -d $out/unwrapped_bin ] && mkdir $out/unwrapped_bin
          WRAPPED_FILE_PATH="$out/unwrapped_bin/$(basename $FILE_PATH)"
          mv $FILE_PATH $WRAPPED_FILE_PATH
          makeWrapper ${fhsEnv}/bin/${pname}-env $FILE_PATH --add-flags $WRAPPED_FILE_PATH ${lib.strings.concatStringsSep " " exportVarsWrapperArgsList}
        ''
      else
      ''
        if [ -n "${lib.strings.concatStringsSep " " exportVarsWrapperArgsList}" ]; then
          wrapProgram $FILE_PATH ${lib.strings.concatStringsSep " " exportVarsWrapperArgsList}
        fi
      '';
      in ''
        cp -r . $out

        # For setting exported variables (see exportVarsWrapperArgsList).
        TOOL_PATH=$out

        for FILE in $(ls $out/bin); do
          FILE_PATH="$out/bin/$FILE"
          if [[ -x $FILE_PATH ]]; then
            ${wrapCmd}
          fi
        done

        # Fix openocd scripts path
        mkdir $out/openocd-esp32
        ln -s $out/share $out/openocd-esp32
      '';

      meta = with lib; {
        inherit description homepage license;
      };

      passthru = {
        inherit exportVars;
      };
    };

in
builtins.listToAttrs (builtins.map (toolSpec: lib.attrsets.nameValuePair toolSpec.name (toolSpecToDerivation toolSpec)) toolSpecList)
