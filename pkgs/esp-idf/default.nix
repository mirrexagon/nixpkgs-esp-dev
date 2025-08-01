{
  owner ? "espressif",
  repo ? "esp-idf",
  rev ? "v5.5",
  sha256 ? "sha256-5G3IBVkpt8uuFzazwVHiwnqfMig3aMYmfcpKyMPWCBI=",
  toolsToInclude ? [
    "xtensa-esp-elf-gdb"
    "riscv32-esp-elf-gdb"
    "xtensa-esp-elf"
    "esp-clang"
    "riscv32-esp-elf"
    "esp32ulp-elf"
    "openocd-esp32"
    "esp-rom-elfs"
  ],
  stdenv,
  lib,
  fetchFromGitHub,
  makeWrapper,
  callPackage,

  python3,

  # Tools for using ESP-IDF.
  git,
  wget,
  gnumake,
  flex,
  bison,
  gperf,
  pkg-config,
  cmake,
  ninja,
  ncurses5,
  dfu-util,
}:

let
  src = fetchFromGitHub {
    inherit
      owner
      repo
      rev
      sha256
      ;
    fetchSubmodules = true;
  };

  allTools = callPackage (import ./tools.nix) {
    toolSpecList = (builtins.fromJSON (builtins.readFile "${src}/tools/tools.json")).tools;
    versionSuffix = "esp-idf-${rev}";
  };

  tools = lib.getAttrs toolsToInclude allTools;

  toolEnv = lib.mergeAttrsList (lib.mapAttrsToList (_: tool: tool.exportVars) tools);

  customPython = (
    python3.withPackages (
      pythonPackages:
      let
        customPythonPackages = callPackage (import ./python-packages.nix) { inherit pythonPackages; };
      in
      with pythonPackages;
      with customPythonPackages;
      [
        # This list is from `tools/requirements/requirements.core.txt` in the
        # ESP-IDF checkout.
        setuptools
        click
        pyserial
        cryptography
        pyparsing
        pyelftools
        idf-component-manager
        esp-coredump
        esptool
        esp-idf-diag
        esp-idf-kconfig
        esp-idf-monitor
        esp-idf-nvs-partition-gen
        esp-idf-panic-decoder
        esp-idf-size
        pyclang
        psutil
        rich
        argcomplete

        freertos_gdb

        # The esp idf vscode extension seems to want pip, too
        pip
      ]
    )
  );
in
stdenv.mkDerivation rec {
  pname = "esp-idf";
  version = rev;

  inherit src;

  # This is so that downstream derivations will have IDF_PATH set.
  setupHook = ./setup-hook.sh;

  nativeBuildInputs = [ makeWrapper ];

  propagatedBuildInputs = [
    # This is in propagatedBuildInputs so that downstream derivations will run
    # the Python setup hook and get PYTHONPATH set up correctly.
    customPython

    # Tools required to use ESP-IDF.
    git
    wget
    gnumake

    flex
    bison
    gperf
    pkg-config

    cmake
    ninja

    ncurses5

    dfu-util
  ] ++ builtins.attrValues tools;

  # We are including cmake and ninja so that downstream derivations (eg. shells)
  # get them in their environment, but we don't actually want any of their build
  # hooks to run, since we aren't building anything with them right now.
  dontUseCmakeConfigure = true;
  dontUseNinjaBuild = true;
  dontUseNinjaInstall = true;
  dontUseNinjaCheck = true;

  __structuredAttrs = true;
  inherit toolEnv;

  installPhase = ''
    mkdir -p $out
    cp -rv . $out/

    # Inspired from how idf.py find the version in the sources.
    # https://github.com/espressif/esp-idf/blob/4e036983a751e4667ade94c8f6f6bf1e7f78eff0/tools/idf_py_actions/tools.py#L82
    IDF_VERSION=$(cat $out/tools/cmake/version.cmake | awk '
      /set\(IDF_VERSION_MAJOR/ && match($0, /[0-9]+/, m) { major = m[0] }
      /set\(IDF_VERSION_MINOR/ && match($0, /[0-9]+/, m) { minor = m[0] }
      /set\(IDF_VERSION_PATCH/ && match($0, /[0-9]+/, m) { patch = m[0] }
      END { print major "." minor "." patch }
    ')
    echo "v$IDF_VERSION" > $out/version.txt

    # Link the Python environment in so that:
    # - The setup hook can set IDF_PYTHON_ENV_PATH to it.
    # - In shell derivations, the Python setup hook will add the site-packages
    #   directory to PYTHONPATH.
    ln -s ${customPython} $out/python-env
    ln -s ${customPython}/lib $out/lib

    for key in "''${!toolEnv[@]}"; do
      printf "export $key=%q" "''${toolEnv[$key]}"
    done > $out/.tool-env

    # make esp-idf cmake git version detection happy
    cd $out
    git init .
    git config user.email "nixbld@localhost"
    git config user.name "nixbld"
    git commit --date="1970-01-01 00:00:00" --allow-empty -m "make idf happy"

    # Create a version tag so git describe works
    git tag "$(cat $out/version.txt)" HEAD

    # Fix Ownership/Permissions Issues with esp-idf repo
    #   - This package is typically built by a different user than the "end user"
    #   - The esp-idf build tools execute git on its own working tree, which requires end user access
    #   - It is not feasible to change ownership or permissions of nix store content, and we don't want to just run as root, so
    #     the solution it to explicitly configure the git client to trust the esp-idf directory in the nix store
    #   - Here we add a system-level git configuration file in the package derivation.
    #   - Git config file location is referred to by the GIT_CONFIG_GLOBAL var exported by shell hook at runtime
    #   - User- and repo-level git configs are not masked, all are read and merged per https://git-scm.com/docs/git-config#FILES
    mkdir -p $out/etc
    cat > $out/etc/gitconfig << EOF
[safe]
	directory = $out
EOF
  '';

  passthru = {
    inherit tools allTools toolEnv;
  };
}
