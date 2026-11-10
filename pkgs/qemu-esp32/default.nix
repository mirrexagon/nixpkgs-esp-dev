{
  qemu,
  fetchFromGitHub,
  cacert,
  git,
  meson,
  lib,
  libgcrypt,
}:

(qemu.override {
  hostCpuTargets = [ "xtensa-softmmu" ];
  capstoneSupport = false;
  guestAgentSupport = false;
  smartcardSupport = false;
  tpmSupport = false;
  libiscsiSupport = false;
  numaSupport = false;

  # no need for graphics
  gtkSupport = false;
  vncSupport = false;
  sdlSupport = false;
  openGLSupport = false;
  spiceSupport = false;

  # no need for audio
  alsaSupport = false;
  pulseSupport = false;
  pipewireSupport = false;
  jackSupport = false;
}).overrideAttrs
  (
    {
      configureFlags ? [ ],
      buildInputs ? [ ],
      patches ? [ ],
      postInstall ? "",
      meta ? { },
      ...
    }:
    {
      version = "9.2.2";

      src = fetchFromGitHub {
        owner = "espressif";
        repo = "qemu";
        rev = "esp-develop-9.2.2-20261109";
        hash = "sha256-pulaP1v7xAuTeEVREhyk7CS6YK2nrN8Kv0UQUcBDzr0=";
        nativeBuildInputs = [
          cacert
          git
          meson
        ];
        postFetch = ''
          (
            cd "$out"
            for prj in subprojects/*.wrap; do
              meson subprojects download "$(basename "$prj" .wrap)"
              rm -rf subprojects/$(basename "$prj" .wrap)/.git
            done
          )
        '';
      };

      configureFlags = configureFlags ++ [
        "--enable-gcrypt"
        "--enable-slirp"
      ];

      # tests/qtest/migration/tls-tests.c does not exist in the Espressif fork
      patches = builtins.filter (
        p: !(lib.hasSuffix "fix-tls-tests-without-tasn1.patch" (baseNameOf (toString p)))
      ) patches;

      buildInputs = buildInputs ++ [
        libgcrypt
      ];

      # remove broken symlink
      postInstall =
        postInstall
        + ''
          rm $out/bin/qemu-kvm
        '';

      meta = meta // {
        description = meta.description + " (Espressif fork)";
        mainProgram = "qemu-system-xtensa";
        longDescription = ''
          Documentation:
          https://docs.espressif.com/projects/esp-idf/en/latest/esp32/api-guides/tools/qemu.html
          https://github.com/espressif/esp-toolchain-docs/tree/main/qemu/esp32
        '';
      };
    }
  )
