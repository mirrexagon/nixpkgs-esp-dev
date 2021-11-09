{ stdenv, lib, fetchurl, makeWrapper, buildFHSUserEnv }:

let
  fhsEnv = buildFHSUserEnv {
    name = "esp32-openocd-env";
    targetPkgs = pkgs: with pkgs; [ zlib libusb1 ];
    runScript = "";
  };
in
stdenv.mkDerivation rec {
  pname = "openocd";
  version = "0.10.0-esp32-20210902";

  src = fetchurl {
    url = "https://github.com/espressif/openocd-esp32/releases/download/v${version}/openocd-esp32-linux64-${version}.tar.gz";
    hash = "sha256-vXNkuL9PoD7rusf4q6hjICnDSUbuZ9RRwCGCqui8OOA=";
  };

  buildInputs = [ makeWrapper ];

  phases = [ "unpackPhase" "installPhase" ];

  installPhase = ''
    cp -r . $out
    for FILE in $(ls $out/bin); do
      FILE_PATH="$out/bin/$FILE"
      if [[ -x $FILE_PATH ]]; then
        mv $FILE_PATH $FILE_PATH-unwrapped
        makeWrapper ${fhsEnv}/bin/esp32-openocd-env $FILE_PATH --add-flags "$FILE_PATH-unwrapped"
      fi
    done
  '';

  meta = with lib; {
    description = "ESP32 toolchain";
    homepage = https://docs.espressif.com/projects/esp-idf/en/stable/get-started/linux-setup.html;
    license = licenses.gpl3;
  };
}

