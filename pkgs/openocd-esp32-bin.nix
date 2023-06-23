{ version ? "0.11.0-esp32-20221026"
, hash ? "sha256-zmPpsd+rYMxi2l3Cq8wiunA2xCr+dGcceH6wJnROfQs="
, stdenv
, lib
, fetchurl
, makeWrapper
, buildFHSUserEnv
}:

let
  fhsEnv = buildFHSUserEnv {
    name = "openocd-esp32-env";
    targetPkgs = pkgs: with pkgs; [ zlib libusb1 ];
    runScript = "";
  };
in
stdenv.mkDerivation rec {
  pname = "openocd-esp32";
  inherit version;

  src = fetchurl {
    url = "https://github.com/espressif/openocd-esp32/releases/download/v${version}/openocd-esp32-linux-amd64-${version}.tar.gz";
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
        makeWrapper ${fhsEnv}/bin/openocd-esp32-env $FILE_PATH --add-flags "$FILE_PATH-unwrapped"
      fi
    done
  '';

  meta = with lib; {
    description = "ESP32-compatible OpenOCD";
    homepage = "https://github.com/espressif/openocd-esp32";
    license = licenses.gpl3;
  };
}

