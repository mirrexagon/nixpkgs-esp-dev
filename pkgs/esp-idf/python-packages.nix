# Versions based on
# https://dl.espressif.com/dl/esp-idf/espidf.constraints.v5.3.txt
# on 2024-10-23.
#
# Versions found by running this in a fresh venv:
# pip install -r esp-idf/tools/requirements/requirements.core.txt --constraint=espidf.constraints.v5.3.txt --dry-run

{
  stdenv,
  lib,
  fetchPypi,
  fetchurl,
  fetchFromGitHub,
  pythonPackages,
}:

with pythonPackages;

rec {
  idf-component-manager = buildPythonPackage rec {
    pname = "idf-component-manager";
    version = "2.1.2";
    pyproject = true;

    src = fetchPypi {
      inherit version;
      pname = "idf_component_manager";
      sha256 = "sha256-Uc80Rlp4GkjW66e1gkl3pQ10e0Q01Pi2jEWSUpc6sLI=";
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
    ] ++ cachecontrol.optional-dependencies.filecache;

    meta = {
      homepage = "https://github.com/espressif/idf-component-manager";
    };
  };

  esp-coredump = buildPythonPackage rec {
    pname = "esp-coredump";
    version = "1.12.0"; # TODO: 1.13.1 returns 404 when downloading
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

  esp-idf-diag = buildPythonPackage rec {
    pname = "esp-idf-diag";
    version = "0.1.1";
    pyproject = true;

    src = fetchurl {
      url = "https://files.pythonhosted.org/packages/5f/d9/b9817b5c3859a5434a1d4d734c39fc6556913e7e771f65971df9a7d092b6/esp_idf_diag-0.1.1.tar.gz";
      sha256 = "4ba922921e957ac6286fc0c0070909eba56584ef0abed2f4fde0fb08c63ff227";
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
    version = "1.5.0"; # TODO: 1.6.2 and 1.6.0 return 404 when downloading
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
    version = "1.6.1";

    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-Oki21JiHiS7PzfIj/uQXSjc1KArRKBEDDLRvpQqBI/o=";
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
    version = "0.1.6";
    pyproject = true;

    src = fetchPypi {
      inherit version;
      pname = "esp_idf_nvs_partition_gen";
      hash = "sha256-511QNGnWJun37fOcH+A923mXM4YDWw/E0kppnNcdiJQ=";
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
    version = "0.6.0";

    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-G+Y24AiTOpjLg+eQGAT/CTCK0/vomqjNZloXTmWqRQM=";
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
    version = "1.3.0";

    format = "pyproject";

    src = fetchPypi {
      inherit version;
      pname = "esp_idf_panic_decoder";
      sha256 = "sha256-INLVdgoLNVl0Mik9MyVCXoQRt34eVnvvaiBO0KuSSTI=";
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
