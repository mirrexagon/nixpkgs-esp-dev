{ stdenv, fetchFromGitHub, fetchurl,
  which, autoconf, libtool, automake,
  gperf, bison, flex, texinfo, wget, help2man, ncurses,
  python27Packages }:

stdenv.mkDerivation rec {
  name = "crosstool-ng-xtensa";

  src = fetchFromGitHub {
    owner = "espressif";
    repo = "crosstool-NG";
    rev = "6c4433a51e4f2f2f9d9d4a13e75cd951acdfa80c";
    sha256 = "03qg9vb0mf10nfslggmb7lc426l0gxqhfyvbadh86x41n2j6ddg6";
  };

  mforce-l32_patch = fetchurl {
    url = "https://github.com/jcmvbkbc/gcc-xtensa/commit/6b0c9f92fb8e11c6be098febb4f502f6af37cd35.patch";
    sha256 = "0nx1vahlq71vr08c8g1s3w5kka19wss0l3i38ma4kxa2sc0jk856";
  };

  nativeBuildInputs = [
    autoconf
    libtool
    automake

    which
  ];

  buildInputs = [
    gperf
    bison
    flex
    texinfo
    wget
    help2man
    ncurses

    python27Packages.python
  ];

  postPatch = ''
    # Expat on SourceForge 404s, get from GitHub instead.
    sed -i "s%--progress=dot:binary%--progress=dot:binary --no-check-certificate%" scripts/functions
    sed -i "s%http://downloads.sourceforge.net/project/expat/expat/.*$%https://github.com/libexpat/libexpat/releases/download/R_2_1_0%" scripts/build/companion_libs/210-expat.sh
    cat scripts/build/companion_libs/210-expat.sh | grep -C 5 github
  '';

  configurePhase = ''
    ./bootstrap && ./configure --prefix=$out
  '';

  buildPhase = ''
    make
  '';

  installPhase = ''
    make install

    cp -r overlays $out/lib

    cp -r local-patches $out/lib
    cp ${mforce-l32_patch} $out/lib/local-patches/gcc/4.8.5/1000-mforce-l32.patch
  '';
}
