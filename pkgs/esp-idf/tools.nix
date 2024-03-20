{ toolSpecList # The `tools` entry in `tools/tools.json` in an ESP-IDF checkout.
, versionSuffix # A string to use in the version of the tool derivations.

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
  toolFhsEnvTargetPackages = {
    xtensa-esp-elf-gdb = pkgs: (with pkgs; [ ]);
    riscv32-esp-elf-gdb = pkgs: (with pkgs; [ ]);
    xtensa-esp32-elf = pkgs: (with pkgs; [ ]);
    xtensa-esp32s2-elf = pkgs: (with pkgs; [ ]);
    xtensa-esp32s3-elf = pkgs: (with pkgs; [ ]);
    esp-clang = pkgs: (with pkgs; [ zlib libxml2 ]);
    riscv32-esp-elf = pkgs: (with pkgs; [ ]);
    esp32ulp-elf = pkgs: (with pkgs; [ ]);
    openocd-esp32 = pkgs: (with pkgs; [ zlib libusb1 udev ]);
  };
  # Map nix system strings to the platforms listed in tools.json
  systemToToolPlatformString = {
    "x86_64-linux" = "linux-amd64";
    "x86_64-darwin" = "macos";
    "aarch64-darwin" = "macos-arm64";
  };

  toolSpecToDerivation = toolSpec:
    let
      targetPlatform = systemToToolPlatformString.${system};
      targetVersionSpec = (builtins.elemAt toolSpec.versions 0).${targetPlatform};
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
      targetPkgs = toolFhsEnvTargetPackages."${toolSpec.name}";
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
        wrapCmd = if system == "linux-x86_64" then
        ''
          makeWrapper ${fhsEnv}/bin/${pname}-env $FILE_PATH --add-flags "$FILE_PATH-unwrapped" ${lib.strings.concatStringsSep " " exportVarsWrapperArgsList}
          mv $FILE_PATH $FILE_PATH-unwrapped
        ''
      else
      ''wrapProgram $FILE_PATH ${lib.strings.concatStringsSep " " exportVarsWrapperArgsList}'';
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
      '';

      meta = with lib; {
        inherit description homepage license;
      };
    };

in
builtins.listToAttrs (builtins.map (toolSpec: lib.attrsets.nameValuePair toolSpec.name (toolSpecToDerivation toolSpec)) toolSpecList)

