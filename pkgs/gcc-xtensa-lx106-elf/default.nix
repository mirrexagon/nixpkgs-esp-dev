{ stdenv, fetchFromGitHub, crosstool-ng-xtensa, wget, which, autoconf, libtool, automake, texinfo, python27Packages, file }:

stdenv.mkDerivation rec {
  name = "gcc-${targetTriple}";
  targetTriple = "xtensa-lx106-elf";

  libhal = fetchFromGitHub {
    owner = "tommie";
    repo = "lx106-hal";
    rev = "e4bcc63c9c016e4f8848e7e8f512438ca857531d";
    sha256 = "1pia9gmzzl64dafg36v2rwxp1r11lhg01jf7fg424v47q2f8wl0c";
  };

  crosstool-config-overrides = ./crosstool-config-overrides;

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
    
    cat ${crosstool-config-overrides} >> .config

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

    # libhal
    cp -r ${libhal} libhal
    chmod -R +w libhal

    cd libhal

    autoreconf -i

    export PATH="$out/bin:$PATH"
    export CC="$out/bin/${targetTriple}-gcc"

    ./configure --host=${targetTriple} --prefix=$out/${targetTriple}/sysroot/usr
    make

    chmod -R +w $out
    make install
  '';
}
