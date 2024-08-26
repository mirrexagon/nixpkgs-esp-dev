# Versions based on
# https://dl.espressif.com/dl/esp-idf/espidf.constraints.v5.2.txt
# on 2024-02-20.

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
    version = "2.0.2";
    pyproject = true;

    src = fetchPypi {
      inherit version;
      pname = "idf_component_manager";
      sha256 = "sha256-aPpejbLkbm7oExy0QuC6ZqGYBK4OpYWM0zQnnfkhcsU=";
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
    version = "1.11.0";
    pyproject = true;

    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-xCt9TsTWklD0GcHfI9gHQiVhADZFjmiPQaleE5HdBNc=";
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
    version = "4.7.0";

    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-AUVOaeHvNgEhXbg/8ssfx57OZ9JLDl1D1FG0EER8SJM=";
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
    version = "1.4.0";
    pyproject = true;

    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-CaX/eA16f4LBU6nUwrIrnlRw2s7CGezOlrHD3dpP8ok=";
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
    version = "1.5.0";

    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-2Xr8nZl6Td/fRz3BjxVy+zTWE5VQDxFiGLuYTq2fZXs=";
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
    version = "0.1.2";
    pyproject = true;

    src = fetchPypi {
      inherit version;
      pname = "esp_idf_nvs_partition_gen";
      hash = "sha256-HjW5RCKfy83LQgAs0tOW/f9LPVoLwHY1pyb6ar+AxwY=";
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
    version = "0.4.2";

    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-vuDZ5yEhyDpCmkXoC+Gr2X5vMK5B46HnktcvBONjxXM=";
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
    version = "1.1.0";

    format = "pyproject";
    
    src = fetchPypi {
      inherit version;
      pname = "esp_idf_panic_decoder";
      sha256 = "sha256-PR8M7VkxAW08QBU8XvE9FwNwejxmXm9GfdrtgMDCmOw=";
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

