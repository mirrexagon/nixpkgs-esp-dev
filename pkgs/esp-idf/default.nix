{ rev ? "v5.0.2"
, sha256 ? "sha256-dlmtTjoz4qQdFG229v9bIHKpYBzjM44fv+XhdDBu2Os="
, toolsToInclude ? [
    "xtensa-esp-elf-gdb"
    "riscv32-esp-elf-gdb"
    "xtensa-esp32-elf"
    "xtensa-esp32s2-elf"
    "xtensa-esp32s3-elf"
    "xtensa-clang"
    "riscv32-esp-elf"
    "esp32ulp-elf"
    "openocd-esp32"
  ]
, stdenv
, lib
, fetchFromGitHub
, fetchurl
, mach-nix
, makeWrapper
, buildFHSUserEnv

  # Tools for using ESP-IDF.
, git
, wget
, gnumake
, flex
, bison
, gperf
, pkgconfig
, cmake
, ninja
, ncurses5
, dfu-util

  # Dependencies for binary tools.
, zlib
, libusb1
}:

let
  src = fetchFromGitHub {
    owner = "espressif";
    repo = "esp-idf";
    rev = rev;
    sha256 = sha256;
    fetchSubmodules = true;
  };

  pythonEnv =
    let
      # Remove things from requirements.txt that aren't necessary and mach-nix can't parse:
      # - Comment out Windows-specific "file://" line.
      # - Comment out ARMv7-specific "--only-binary" line.
      requirementsOriginalText = builtins.readFile "${src}/tools/requirements/requirements.core.txt";
      requirementsText = builtins.replaceStrings
        [ "file://" "--only-binary" ]
        [ "#file://" "#--only-binary" ]
        requirementsOriginalText;
    in
    mach-nix.mkPython
      {
        requirements = requirementsText;
      };

  allTools =
    let
      toolFhsEnvTargetPackages = {
        xtensa-esp-elf-gdb = pkgs: (with pkgs; [ ]);
        riscv32-esp-elf-gdb = pkgs: (with pkgs; [ ]);
        xtensa-esp32-elf = pkgs: (with pkgs; [ ]);
        xtensa-esp32s2-elf = pkgs: (with pkgs; [ ]);
        xtensa-esp32s3-elf = pkgs: (with pkgs; [ ]);
        xtensa-clang = pkgs: (with pkgs; [ ]);
        riscv32-esp-elf = pkgs: (with pkgs; [ ]);
        esp32ulp-elf = pkgs: (with pkgs; [ ]);
        openocd-esp32 = pkgs: (with pkgs; [ zlib libusb1 ]);
      };

      toolSpecList = (builtins.fromJSON (builtins.readFile "${src}/tools/tools.json")).tools;

      toolSpecToDerivation = toolSpec:
        let
          targetVersionSpec = (builtins.elemAt toolSpec.versions 0).linux-amd64;
        in
        mkToolDerivation {
          pname = toolSpec.name;

          # NOTE: tools.json does not separately specify the versions of tools,
          # so short of extracting the versions from the tarball URLs, we will
          # just put the ESP-IDF version as the tool version.
          version = "esp-idf-${rev}";

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

        assert stdenv.system == "x86_64-linux";

        stdenv.mkDerivation rec {
          inherit pname version;

          src = fetchurl {
            inherit url sha256;
          };

          buildInputs = [ makeWrapper ];

          phases = [ "unpackPhase" "installPhase" ];

          installPhase = ''
            cp -r . $out

            # For setting exported variables (see exportVarsWrapperArgsList).
            TOOL_PATH=$out

            for FILE in $(ls $out/bin); do
              FILE_PATH="$out/bin/$FILE"
              if [[ -x $FILE_PATH ]]; then
                mv $FILE_PATH $FILE_PATH-unwrapped
                makeWrapper ${fhsEnv}/bin/${pname}-env $FILE_PATH --add-flags "$FILE_PATH-unwrapped" ${lib.strings.concatStringsSep " " exportVarsWrapperArgsList}
              fi
            done
          '';

          meta = with lib; {
            inherit description homepage license;
          };
        };

    in
    builtins.listToAttrs (builtins.map (toolSpec: lib.attrsets.nameValuePair toolSpec.name (toolSpecToDerivation toolSpec)) toolSpecList);

  toolDerivationsToInclude = builtins.map (toolName: allTools."${toolName}") toolsToInclude;
in
stdenv.mkDerivation rec {
  pname = "esp-idf";
  version = rev;

  inherit src;

  # This is so that downstream derivations will have IDF_PATH set.
  setupHook = ./setup-hook.sh;

  nativeBuildInputs = [ makeWrapper ];

  propagatedBuildInputs = [
    # This is so that downstream derivations will run the Python setup hook and get PYTHONPATH set up correctly.
    pythonEnv.python

    # Tools required to use ESP-IDF.
    git
    wget
    gnumake

    flex
    bison
    gperf
    pkgconfig

    cmake
    ninja

    ncurses5

    dfu-util
  ] ++ toolDerivationsToInclude;

  # We are including cmake and ninja so that downstream derivations (eg. shells)
  # get them in their environment, but we don't actually want any of their build
  # hooks to run, since we aren't building anything with them right now.
  dontUseCmakeConfigure = true;
  dontUseNinjaBuild = true;
  dontUseNinjaInstall = true;
  dontUseNinjaCheck = true;

  installPhase = ''
    mkdir -p $out
    cp -rv . $out/

    # Link the Python environment in so that:
    # - The setup hook can set IDF_PYTHON_ENV_PATH to it.
    # - In shell derivations, the Python setup hook will add the site-packages
    #   directory to PYTHONPATH.
    ln -s ${pythonEnv} $out/python-env
    ln -s ${pythonEnv}/lib $out/lib
  '';
}
