# Versions based on
# https://dl.espressif.com/dl/esp-idf/espidf.constraints.v5.3.txt
# on 2024-10-23.
#
# Versions found by running this in a fresh venv:
# pip install -r esp-idf/tools/requirements/requirements.core.txt --constraint=espidf.constraints.v5.3.txt --dry-run

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
    version = "2.0.4";
    pyproject = true;

    src = fetchPypi {
      inherit version;
      pname = "idf_component_manager";
      sha256 = "sha256-vCyw3nn1r9zkMbqMhXnS9t2kISTqqB56WqlQVq6/6Cs=";
    };

    build-system = [
      setuptools
    ];
    doCheck = false;

    propagatedBuildInputs = [
      cachecontrol
      cffi
      click
      colorama
      jsonref

      pydantic
      pydantic-core
      pydantic-core
      pydantic-settings
      pyparsing

      packaging
      pyyaml
      requests
      requests-file
      requests-toolbelt
      schema
      six
      tqdm
      typing-extensions
    ] ++ cachecontrol.optional-dependencies.filecache;

    meta = {
      homepage = "https://github.com/espressif/idf-component-manager";
    };
  };

  esp-coredump = buildPythonPackage rec {
    pname = "esp-coredump";
    version = "1.12.0";
    pyproject = true;

    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-s/JKD9PwcU7OZ3x4U4ScCRILvc1Ors0hkXHiRV+R+tg=";
    };

    build-system = [
      setuptools
    ];

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
    version = "4.8.1";

    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-3E7ya2WeGo3LAZFHwOptlJgLNN6Z++CRIceUHIslRTE=";
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

    # Replaces esptool.py import with .esptool.py-wrapped
    postInstall = ''
      sed -i "2s|^|\n\
      #fix import esptool patch\n\
      import importlib.util\n\
      import importlib.machinery\n\
      esptool_loader = importlib.machinery.SourceFileLoader(\"esptool\", \"$out/bin/.esptool.py-wrapped\")\n\
      esptool_spec = importlib.util.spec_from_loader(\"esptool\", esptool_loader)\n\
      esptool_module = importlib.util.module_from_spec(esptool_spec)\n\
      esptool_spec.loader.exec_module(esptool_module)\n\
      sys.modules[\"esptool\"] = esptool_module\n\
      #end of fix import esptool patch\n|" $out/bin/esp_rfc2217_server.py
    '';

    meta = {
      homepage = "https://github.com/espressif/esptool";
    };
  };

  esp-idf-kconfig = buildPythonPackage rec {
    pname = "esp-idf-kconfig";
    version = "2.3.0";
    pyproject = true;

    build-system = [
      setuptools
    ];

    src = fetchPypi {
      inherit version;
      pname = "esp_idf_kconfig";
      sha256 = "sha256-n+8QM5xe+c8UFl8dTndRTBd4QW7nG1NWiYiEdll06wg=";
    };

    doCheck = false;

    propagatedBuildInputs = [
      kconfiglib

      # These packages aren't declared as dependencies but will fail idf.py's
      # intial depenency check.
      intelhex
      rich
    ];

    meta = {
      homepage = "https://github.com/espressif/esp-idf-kconfig";
    };
  };

  esp-idf-monitor = buildPythonPackage rec {
    pname = "esp-idf-monitor";
    version = "1.5.0";
    pyproject = true;

    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-kGz1uY8KwQ1E/a7YZdZItLou8au5zfHEva/Q/g0aQuQ=";
    };

    build-system = [
      setuptools
    ];

    doCheck = false;

    propagatedBuildInputs = [
      pyserial
      esp-coredump
      pyelftools
      esp-idf-panic-decoder
    ];

    meta = {
      homepage = "https://github.com/espressif/esp-idf-monitor";
    };
  };

  esp-idf-size = buildPythonPackage rec {
    pname = "esp-idf-size";
    version = "1.6.0";

    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-sNgfr3iTlGo4cLUZKEqcQ2YEtL/E66bwjATJN1N8Ir8=";
    };

    doCheck = false;

    propagatedBuildInputs = [
      pyyaml
    ];

    meta = {
      homepage = "https://github.com/espressif/esp-idf-size";
    };
  };

  esp-idf-nvs-partition-gen = buildPythonPackage rec {
    pname = "esp-idf-nvs-partition-gen";
    version = "0.1.3";
    pyproject = true;

    src = fetchPypi {
      inherit version;
      pname = "esp_idf_nvs_partition_gen";
      hash = "sha256-bbD4BoD8Pm/thzwO2wfrMMPWMVsDbNhEvOYm5ERlrP8=";
    };

    build-system = [
      setuptools
    ];

    dependencies = [
      cryptography
    ];

    pythonImportsCheck = [ "esp_idf_nvs_partition_gen" ];

    meta = {
      homepage = "https://pypi.org/project/esp-idf-nvs-partition-gen/";
    };
  };

  pyclang = buildPythonPackage rec {
    pname = "pyclang";
    version = "0.5.0";

    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-stcQaXHkSsXgcz19TUWF27e8O/eWlrvaTKKFk0JeHVQ=";
    };

    doCheck = false;

    meta = {
      homepage = "https://pypi.org/project/pyclang/";
    };
  };

  freertos_gdb = buildPythonPackage rec {
    pname = "freertos-gdb";
    version = "1.0.3";

    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-5rkB01OdbD5Z4vA6dbqhWp5pGwqI1IlE4IE1dSdT1QE=";
    };

    doCheck = false;

    propagatedBuildInputs = [
    ];

    meta = {
      homepage = "https://github.com/espressif/freertos-gdb";
    };
  };

  esp-idf-panic-decoder = buildPythonPackage rec {
    pname = "esp-idf-panic-decoder";
    version = "1.2.1";

    format = "pyproject";

    src = fetchPypi {
      inherit version;
      pname = "esp_idf_panic_decoder";
      sha256 = "sha256-hC8Rje/yMj5qyY8hgErviR4WV3hC0vNCdCQboKXVTYI=";
    };

    doCheck = false;

    propagatedBuildInputs = [
      pyelftools
      setuptools
    ];

    meta = {
      homepage = "https://github.com/espressif/esp-idf-panic-decoder";
    };
  };

}

