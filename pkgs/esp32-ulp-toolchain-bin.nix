{ version ? "2.35_20220830"
, hash ? "sha256-sfeAHDoWFi5yOT67dywMv+TSLZB758LC2sFoc26Rlf0="
, stdenv
, lib
, fetchurl
, makeWrapper
, buildFHSUserEnv
}:

let
  fhsEnv = buildFHSUserEnv {
    name = "esp32-ulp-toolchain-env";
    targetPkgs = pkgs: with pkgs; [ zlib libusb1 ];
    runScript = "";
  };
in
stdenv.mkDerivation rec {
  pname = "esp32-ulp-toolchain";
  inherit version;

  src = fetchurl {
    url = "https://github.com/espressif/binutils-gdb/releases/download/esp32ulp-elf-v${version}/esp32ulp-elf-${version}-linux-amd64.tar.gz";
    inherit hash;
  };

  buildInputs = [ makeWrapper ];

  phases = [ "unpackPhase" "installPhase" ];

  installPhase = ''
    cp -r . $out
    for FILE in $(ls $out/bin); do
      FILE_PATH="$out/bin/$FILE"
      if [[ -x $FILE_PATH ]]; then
        mv $FILE_PATH $FILE_PATH-unwrapped
        makeWrapper ${fhsEnv}/bin/esp32-ulp-toolchain-env $FILE_PATH --add-flags "$FILE_PATH-unwrapped"
      fi
    done
  '';

  meta = with lib; {
    description = "ESP32 ULP co-processor toolchain";
    homepage = "https://github.com/espressif/binutils-gdb";
    license = licenses.gpl3;
  };
}

