{ stdenv
, lib
, fetchFromGitHub

, gnumake

, gcc-xtensa-lx106-elf-bin
, esptool
}:

stdenv.mkDerivation rec {
  pname = "esp8266-nonos-sdk";
  version = "3.0.5";

  src = fetchFromGitHub {
    owner = "espressif";
    repo = "ESP8266_NONOS_SDK";
    rev = "7b5b35da98ad9ee2de7afc63277d4933027ae91c";
    sha256 = "sha256-AJy7A8W0RT+bSy80sNjoK1YsfNbvkkKkWKihkeXT5Rs=";
    fetchSubmodules = true;
  };

  setupHook = ./setup-hook.sh;

  propagatedBuildInputs = [
    gcc-xtensa-lx106-elf-bin

    gnumake
    esptool
  ];

  buildPhase = "true";

  installPhase = ''
    chmod -x ./tools/*
    chmod +x ./tools/*.sh
    cp -r . $out
  '';

  meta = with lib; {
    description = "ESP8266 nonOS SDK";
    license = licenses.mit;
  };
}
