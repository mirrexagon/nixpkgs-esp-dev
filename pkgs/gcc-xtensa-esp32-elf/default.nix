{ stdenv, fetchFromGitHub, crosstool-ng-xtensa, wget, which, autoconf, libtool, automake, texinfo, python27Packages, file }:

stdenv.mkDerivation rec {
  name = "gcc-${targetTriple}";
  targetTriple = "xtensa-esp32-elf";

  nativeBuildInputs = [
    autoconf
    libtool
    automake
    wget
    which
    texinfo
    python27Packages.python
    file
    crosstool-ng-xtensa
  ];

  buildInputs = [

  ];

  phases = [ "configurePhase" "buildPhase" ];

  # https://github.com/jcmvbkbc/crosstool-NG/issues/48
  hardeningDisable = [ "format" ];

  configurePhase = ''
    ${crosstool-ng-xtensa}/bin/ct-ng ${targetTriple}
    
    # Put toolchain in $out.
    sed -r -i.org "s%CT_PREFIX_DIR=.*%CT_PREFIX_DIR=\"$out\"%" .config

    # Increase the verbosity of crosstool-NG.
    sed -r -i.org "s%CT_LOG_LEVEL_MAX=.*%CT_LOG_LEVEL_MAX=ALL%" .config
    sed -r -i.org "s%CT_LOG_PROGRESS_BAR=.*%CT_LOG_PROGRESS_BAR=n%" .config
    sed -r -i.org "s%# CT_LOG_ALL is not set%CT_LOG_ALL=y%" .config
    sed -r -i.org "s%# CT_LOG_EXTRA is not set%CT_LOG_EXTRA=y%" .config
  '';

  buildPhase = ''
    ${crosstool-ng-xtensa}/bin/ct-ng build
  '';
}
