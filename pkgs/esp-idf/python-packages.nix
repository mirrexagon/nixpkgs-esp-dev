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
with pythonPackages;
rec {
  idf-component-manager = buildPythonPackage rec {
    pname = "idf-component-manager";
    version = "2.4.2";
    pyproject = true;

    src = fetchPypi {
      inherit version;
      pname = "idf_component_manager";
      sha256 = "sha256-P93LjDZFARmy2S8oIe6uB//JyN2bSU++3oInyLE2vMk=";
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
    version = "1.14.0";
    pyproject = true;

    src = fetchPypi {
      inherit version;
      pname = "esp_coredump";
      sha256 = "sha256-HDqIHObATfq408mDzpN8WQDIQxfpZFnK2L+LWEcrhzs=";
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
    version = "5.1.0";
    pyproject = true;

    build-system = [
      setuptools
    ];

    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-Lqm81+smPTgKT+AXCFahDkxl4/OMdX69xzWEyN2DIto=";
    };

    doCheck = false;

    propagatedBuildInputs = [
      argcomplete
      bitstring
      click
      cryptography
      ecdsa
      intelhex
      pyserial
      pyyaml
      reedsolo
      rich-click
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
    version = "3.3.0";
    pyproject = true;

    build-system = [
      setuptools
    ];

    src = fetchPypi {
      inherit version;
      pname = "esp_idf_kconfig";
      sha256 = "sha256-M4kOVDI/dxX5BlxTCbERztZdKiu+5Od81oSvTRNqllo=";
    };

    doCheck = false;

    propagatedBuildInputs = [
      kconfiglib
      pyparsing

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
    version = "1.8.0";
    pyproject = true;

    src = fetchPypi {
      inherit version;
      pname = "esp_idf_monitor";
      sha256 = "sha256-jCJPOBBd+BadDZos0YIV7L3114gBvsLlA4xQLYRxl/8=";
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
    version = "2.0.0";
    pyproject = true;

    build-system = [
      setuptools
    ];

    src = fetchPypi {
      inherit version;
      pname = "esp_idf_size";
      sha256 = "sha256-EmPMN7Ypnv0/zCCzClKG4cVr+Yo91q0R7mV2Pc+CrEI=";
    };

    doCheck = false;

    propagatedBuildInputs = [
      rich
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

    pythonImportsCheck = [ "esp_idf_nvs_partition_gen" ];

    meta = {
      homepage = "https://pypi.org/project/esp-idf-nvs-partition-gen/";
    };
  };

  pyclang = buildPythonPackage rec {
    pname = "pyclang";
    version = "0.6.3";
    pyproject = true;

    build-system = [
      setuptools
    ];

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
    pyproject = true;

    build-system = [
      setuptools
    ];

    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-lH/dlTX2PuZ89rX5zzpedHkqHvdVy+h6BzJ8rVFmkb8=";
    };

    doCheck = false;

    meta = {
      homepage = "https://github.com/espressif/freertos-gdb";
    };
  };

  esp-idf-panic-decoder = buildPythonPackage rec {
    pname = "esp-idf-panic-decoder";
    version = "1.4.2";
    pyproject = true;

    build-system = [
      setuptools
    ];

    src = fetchPypi {
      inherit version;
      pname = "esp_idf_panic_decoder";
      sha256 = "sha256-wjk2lUISeipxw7CDIORQTxKSC2QAW0cjYqM+wkBk9/U=";
    };

    doCheck = false;

    propagatedBuildInputs = [
      pyelftools
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
