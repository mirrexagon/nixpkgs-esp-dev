{ stdenv, lib, fetchurl, makeWrapper, buildFHSUserEnv }:

let
  fhsEnv = buildFHSUserEnv {
    name = "esp8266-toolchain-env";
    targetPkgs = pkgs: with pkgs; [ zlib ];
    runScript = "";
  };
in

assert stdenv.system == "x86_64-linux";

stdenv.mkDerivation rec {
  pname = "esp8266-toolchain";
  version = "2020r3";

  src = fetchurl {
    url = "https://dl.espressif.com/dl/xtensa-lx106-elf-gcc8_4_0-esp-${version}-linux-amd64.tar.gz";
    hash = "sha256-ChgEteIjHG24tyr2vCoPmltplM+6KZVtQSZREJ8T/n4=";
  };

  buildInputs = [ makeWrapper ];

  phases = [ "unpackPhase" "installPhase" ];

  installPhase = ''
    cp -r . $out
    for FILE in $(ls $out/bin); do
      FILE_PATH="$out/bin/$FILE"
      if [[ -x $FILE_PATH ]]; then
        mv $FILE_PATH $FILE_PATH-unwrapped
        makeWrapper ${fhsEnv}/bin/esp8266-toolchain-env $FILE_PATH --add-flags "$FILE_PATH-unwrapped"
      fi
    done
  '';

  meta = with lib; {
    description = "ESP8266 compiler toolchain";
    homepage = "https://docs.espressif.com/projects/esp8266-rtos-sdk/en/latest/get-started/linux-setup.html";
    license = licenses.gpl3;
  };
}

