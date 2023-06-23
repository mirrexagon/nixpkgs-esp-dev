# This version needs to be compatible with the version of ESP-IDF specified in `esp-idf/default.nix`.
{ version ? "2022r1"
, gccVersion ? "11_2_0"
, hash ? "sha256-UFiy5yQWbDTKCewtU3c1AlLei85QObBsADUvmoFR924="
, stdenv
, lib
, fetchurl
, makeWrapper
, buildFHSUserEnv
}:

let
  fhsEnv = buildFHSUserEnv {
    name = "esp32s3-toolchain-env";
    targetPkgs = pkgs: with pkgs; [ zlib ];
    runScript = "";
  };
in

assert stdenv.system == "x86_64-linux";

stdenv.mkDerivation rec {
  pname = "esp32s3-toolchain";
  inherit version;

  src = fetchurl {
    url = "https://github.com/espressif/crosstool-NG/releases/download/esp-${version}/xtensa-esp32s3-elf-gcc${gccVersion}-esp-${version}-linux-amd64.tar.xz";
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
        makeWrapper ${fhsEnv}/bin/esp32s3-toolchain-env $FILE_PATH --add-flags "$FILE_PATH-unwrapped"
      fi
    done
  '';

  meta = with lib; {
    description = "ESP32-S3 compiler toolchain";
    homepage = "https://docs.espressif.com/projects/esp-idf/en/stable/get-started/linux-setup.html";
    license = licenses.gpl3;
  };
}

