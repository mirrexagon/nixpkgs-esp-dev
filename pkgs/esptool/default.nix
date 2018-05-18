{ stdenv, fetchurl, fetchFromGitHub, makeWrapper, zip, python35Packages }:

with python35Packages;
let
  pyaes = buildPythonPackage rec {
    name = "pyaes-${version}";
    version = "1.6.1";

    src = fetchurl {
      url = "mirror://pypi/p/pyaes/${name}.tar.gz";
      sha256 = "13vdaff15k0jyfcss4b4xvfgm8xyv0nrbyw5n1qc7lrqbi0b3h82";
    };
  };
in buildPythonApplication rec {
  name = "esptool-${version}";
  version = "2.3.1";

  src = fetchFromGitHub {
    owner = "espressif";
    repo = "esptool";
    rev = "v${version}";
    sha256 = "0gwnl6z5s2ax07l3n38h9hdyz71pn8lzn4fybcwyrii0bj2kapvc";
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
