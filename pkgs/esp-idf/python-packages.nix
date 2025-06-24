# Versions based on
# https://dl.espressif.com/dl/esp-idf/espidf.constraints.v5.5.txt
# on 2025-07-18.
#
# Versions found by running this in a fresh venv:
# pip install -r esp-idf/tools/requirements/requirements.core.txt --constraint=espidf.constraints.v5.5.txt --dry-run
{
  fetchPypi,
  fetchurl,
  pythonPackages,
}:
with pythonPackages; rec {
  idf-component-manager = buildPythonPackage rec {
    pname = "idf-component-manager";
    version = "2.2.2";
    pyproject = true;

    src = fetchPypi {
      inherit version;
      pname = "idf_component_manager";
      sha256 = "sha256-HKOJIThQ05khSBhDzVjX+cF2hWrBivNZXmQZWBpIGvc=";
    };

    build-system = [
      setuptools
    ];
    doCheck = false;

    propagatedBuildInputs =
      [
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
        ruamel-yaml
        requests
        requests-file
        requests-toolbelt
        schema
        six
        tqdm
        typing-extensions
        truststore
      ]
      ++ cachecontrol.optional-dependencies.filecache;

    meta = {
      homepage = "https://github.com/espressif/idf-component-manager";
    };
  };

  esp-coredump = buildPythonPackage rec {
    pname = "esp-coredump";
    version = "1.13.1";
    pyproject = true;

    src = fetchPypi {
      inherit version;
      pname = "esp_coredump";
      sha256 = "sha256-rz0HbQ4DHB7vClZICYW/Q13N+48MWqEpnup0TyYFzIk=";
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
    version = "4.9.1";

    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-qMDmKxZGkik1wqG6knfuMNYy6ziiH92z603iJ9j+07o=";
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
    version = "2.5.0";
    pyproject = true;

    build-system = [
      setuptools
    ];

    src = fetchPypi {
      inherit version;
      pname = "esp_idf_kconfig";
      sha256 = "sha256-G65GbZh1tlOITRJG1bDKfHq247f0/1pzLjyAljHg45I=";
    };

    doCheck = false;

    propagatedBuildInputs = [
      kconfiglib

      # These packages aren't declared as dependencies but will fail idf.py's
      # initial dependency check.
      intelhex
      rich
    ];

    meta = {
      homepage = "https://github.com/espressif/esp-idf-kconfig";
    };
  };

  esp-idf-monitor = buildPythonPackage rec {
    pname = "esp-idf-monitor";
    version = "1.7.0";
    pyproject = true;

    src = fetchPypi {
      inherit version;
      pname = "esp_idf_monitor";
      sha256 = "sha256-lU5ec8f7d3R+PzBkfiCVbYbnD7ZO1rOJC3TA5ulKGdk=";
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
    version = "1.7.1";

    src = fetchPypi {
      inherit version;
      pname = "esp_idf_size";
      sha256 = "sha256-labUYKJukzADWq8eHCXM83FgVJdWIUMgzMqEBNl9zBs=";
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
    version = "0.1.9";
    pyproject = true;

    src = fetchPypi {
      inherit version;
      pname = "esp_idf_nvs_partition_gen";
      hash = "sha256-Q6ObVLJDGJ6REJpOmZaMhk8y4g4Ne5wzBSu9JqXxaQ8=";
    };

    build-system = [
      setuptools
    ];

    dependencies = [
      cryptography
    ];

    pythonImportsCheck = ["esp_idf_nvs_partition_gen"];

    meta = {
      homepage = "https://pypi.org/project/esp-idf-nvs-partition-gen/";
    };
  };

  pyclang = buildPythonPackage rec {
    pname = "pyclang";
    version = "0.6.3";

    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-CxFRwZhiGfQcuRpXcyQQlejSKD/qqPlHyYnGWE/E1Wo=";
    };

    doCheck = false;

    meta = {
      homepage = "https://pypi.org/project/pyclang/";
    };
  };

  freertos_gdb = buildPythonPackage rec {
    pname = "freertos-gdb";
    version = "1.0.4";

    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-lH/dlTX2PuZ89rX5zzpedHkqHvdVy+h6BzJ8rVFmkb8=";
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
    version = "1.4.1";

    format = "pyproject";

    src = fetchPypi {
      inherit version;
      pname = "esp_idf_panic_decoder";
      sha256 = "sha256-l0HQFZlWB0PkiK4EkiIotYBkX5hXHCu9v+f0noUcKwM=";
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

  esp-idf-diag = buildPythonPackage {
    pname = "esp-idf-diag";
    version = "0.2.0";
    pyproject = true;

    src = fetchurl {
      url = "https://github.com/espressif/esp-idf-diag/archive/refs/tags/v0.2.0.tar.gz";
      sha256 = "sha256-YEwLBYOveUl1xmZeZScXzY98PLCEWGgomt3t1WjJPJQ=";
    };

    build-system = [
      setuptools
    ];

    doCheck = false;

    propagatedBuildInputs = [
      pyyaml
      click
      rich
    ];

    meta = {
      homepage = "https://github.com/espressif/esp-idf-diag";
      description = "Diagnostic tool for ESP-IDF";
    };
  };
}
