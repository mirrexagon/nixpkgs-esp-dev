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
      ...
    }:
    {
      version = "9.2.2";

      src = fetchFromGitHub {
        owner = "espressif";
        repo = "qemu";
        rev = "esp-develop-9.2.2-20250817";
        hash = "sha256-482BeOmWkaOn2H3inH7sZADsxV331Nssbs+6iYCTFCg=";
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
