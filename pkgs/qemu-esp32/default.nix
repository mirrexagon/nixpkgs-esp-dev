{
  qemu,
  fetchFromGitHub,
  cacert,
  git,
  meson,
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
      postInstall ? "",
      meta ? { },
      patches ? { },
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

      # This patch in currently locked nixpkgs is for a newer version of qemu
      # than the base of this fork, so filter it out.
      patches = builtins.filter (
        x: builtins.baseNameOf x != "fix-tls-tests-without-tasn1.patch"
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
