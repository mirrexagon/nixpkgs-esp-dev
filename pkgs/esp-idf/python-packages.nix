# Versions based on
# https://dl.espressif.com/dl/esp-idf/espidf.constraints.v5.0.txt
# on 2023-06-30.

{ stdenv
, lib
, fetchPypi
, fetchFromGitHub
, pythonPackages
}:

with pythonPackages;

rec {
  idf-component-manager = buildPythonPackage rec {
    pname = "idf-component-manager";
    version = "1.3.0";

    src = fetchFromGitHub {
      owner = "espressif";
      repo = pname;
      rev = "v${version}";
      sha256 = "sha256-J/Sj6YRb/kPx2lPw/1b3YQExhEJK8z2zzqiuFv0Zuac=";
    };

    # For some reason, this 404s.
    /*
      src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-1bozmQ4Eb5zL4rtNHSFjEynfObUkYlid1PgMDVmRkwY=";
      };
    */

    doCheck = false;

    propagatedBuildInputs = [
      cachecontrol
      lockfile
      cffi
      click
      colorama
      contextlib2
      packaging
      pyyaml
      requests
      urllib3
      requests-file
      requests-toolbelt
      schema
      six
      tqdm
    ];

    meta = {
      homepage = "https://github.com/espressif/idf-component-manager";
    };
  };

  esp-coredump = buildPythonPackage rec {
    pname = "esp-coredump";
    version = "1.5.0";

    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-Zni9RkniGQp885h2H40U4oEOoRHF35cF9OfxWQrk4Xg=";
    };

    doCheck = false;

    propagatedBuildInputs = [
      construct
      pygdbmi
      esptool
    ];

    meta = {
      homepage = "https://github.com/espressif/esp-coredump";
    };
  };

  esptool = buildPythonPackage rec {
    pname = "esptool";
    version = "4.5.1";

    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-4+tZg2Ej5ev3k+9jkxH32FZFUmSH2LHCtRFZtFUQa5o=";
    };

    doCheck = false;

    propagatedBuildInputs = [
      bitstring
      cryptography
      ecdsa
      pyserial
      reedsolo
      pyyaml
    ];

    meta = {
      homepage = "https://github.com/espressif/esptool";
    };
  };

  freertos_gdb = buildPythonPackage rec {
    pname = "freertos-gdb";
    version = "1.0.2";

    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-o0ZoTy7OLVnrhSepya+MwaILgJSojs2hfmI86D9C3cs=";
    };

    doCheck = false;

    propagatedBuildInputs = [
    ];

    meta = {
      homepage = "https://github.com/espressif/freertos-gdb";
    };
  };
}

