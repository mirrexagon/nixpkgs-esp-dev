{ stdenv, fetchurl, fetchFromGitHub, makeWrapper, zip, python3Packages }:

with python3Packages;
buildPythonApplication rec {
  name = "esptool-${version}";
  version = "2.8";

  src = fetchFromGitHub {
    owner = "espressif";
    repo = "esptool";
    rev = "v${version}";
    sha256 = "01g8r449kllsmvwxzxgm243c9p7kpj5b9bkrh569zcgg9k2s0xa0";
  };

  buildInputs = [ makeWrapper zip pyserial ];
  propagatedBuildInputs = [ pyserial pyaes ecdsa ];

  doCheck = false;

  meta = with stdenv.lib; {
    homepage = https://github.com/espressif/esptool;
    description = "ESP8266 and ESP32 serial bootloader utility";
    license = licenses.gpl2;
    maintainers = with maintainers; [ mirrexagon ];
  };
}
