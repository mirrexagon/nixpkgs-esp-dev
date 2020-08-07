{ stdenv, fetchFromGitHub, fetchurl,
  which, autoconf, libtool, automake,
  gperf, bison, flex, texinfo, wget, help2man, ncurses,
  python27Packages }:

stdenv.mkDerivation rec {
  name = "crosstool-ng-xtensa";

  src = fetchFromGitHub {
    owner = "jcmvbkbc";
    repo = "crosstool-NG";
    rev = "37b07f6fbea2e5d23434f7e91614528f839db056";
    sha256 = "1rnxdnn7754s65538hmf5kh7h8j56m6ncppahfpwj327sjg8jpkb";
  };

  mforce-l32_patch = fetchurl {
    url = "https://github.com/jcmvbkbc/gcc-xtensa/commit/6b0c9f92fb8e11c6be098febb4f502f6af37cd35.patch";
    sha256 = "1cfdh7jvgg66x4xfbr1zsx7bgrcmj7y81l2wknfc7shdf69ybfax";
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
