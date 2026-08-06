{
  exo.mods.media =
    {
      lib,
      config,
      self',
      ...
    }:
    let
      cfg = config.forte.jellyfin-desktop;
    in
    {
      config = lib.mkIf cfg.enable {
        hj.packages = [ cfg.package ];
        forte.persist.home.directories = [
          ".cache/jellium-desktop"
          ".config/jellium-desktop"
        ];
        forte.hyprland.lua.window-rules = # lua
          ''
            hl.window_rule({
              name             = "jellium-desktop",
              match            = { class = "net.nullsum.JelliumDesktop" },
              workspace        = "name:media",
              fullscreen_state = "0 3",
              opacity          = "1 override",
            })
          '';
      };

      options.forte.jellyfin-desktop = {
        enable = lib.mkEnableOption "jellium-desktop" // {
          default = false;
        };
        package = lib.mkOption {
          type = lib.types.package;
          default = self'.packages.jellium-desktop;
        };
      };
    };
  perSystem =
    { pkgs, ... }:
    let
      jellium-desktop =
        {
          # Nix/Rust packaging helpers
          lib,
          runCommand,
          rustPlatform,
          fetchFromGitHub,
          autoPatchelfHook,
          makeWrapper,

          # CEF
          cef-binary,

          # Build tools and generators
          meson,
          ninja,
          cmake,
          python3,
          pkg-config,
          llvmPackages,

          # Core media playback and codecs
          ffmpeg,
          libass,
          libplacebo,

          # OpenGL/GBM and display infrastructure
          libGL,
          libgbm,
          libdrm,
          libdisplay-info,

          # X11 support
          libx11,
          libxcb,
          libxext,
          libxrandr,
          libxfixes,
          libxpresent,
          libxscrnsaver,

          # Wayland support
          wayland,
          libxkbcommon,
          wayland-scanner,
          wayland-protocols,

          # Hardware video acceleration
          libva,
          vulkan-loader,
          vulkan-headers,
          nv-codec-headers-12,

          # Network and disc media support
          curl,
          libcdio,

          # Archive and scripting support
          lua,
          mujs,
          libarchive,

          # Audio processing and output
          alsa-lib,
          pipewire,
          rubberband,
          pulseaudio,
          libcdio-paranoia,

          # Image, terminal graphics, and visual output
          lcms2,
          libjpeg_turbo,

          # Subtitle/text encoding and video filters
          zimg,
          libuchardet,
        }:
        let
          cefBase = cef-binary.override {
            version = "150.0.10";
            gitRevision = "8042e43";
            chromiumVersion = "150.0.7871.101";

            srcHashes = {
              x86_64-linux = "sha256-bB1Ike84huPM9l0JKI2DBOP343JKR8kyk+K9Y+dlKOQ=";
            };
          };

          cef = runCommand "cef-jellium-150.0.10" { } ''
            mkdir -p "$out"

            # Jellium Desktop expects a flat structure
            cp -r ${cefBase}/include "$out"
            cp -r ${cefBase}/Release/* "$out"
            cp -r ${cefBase}/Resources/* "$out"

            chmod -R u+w "$out"
          '';
        in
        rustPlatform.buildRustPackage {
          pname = "jellium-desktop";
          version = "unstable-2026-07-23";
          __structuredAttrs = true;

          env = {
            CEF_PATH = "${cef}";
            LIBCLANG_PATH = "${lib.getLib llvmPackages.libclang}/lib";
          };

          src = fetchFromGitHub {
            owner = "andrewrabert";
            repo = "jellium-desktop";
            rev = "41bcfd7c9a1e26a2b6f418e814e6e44f9227cb6d";
            hash = "sha256-WVFro7kZk83+fG9Ijp+uCG+Yo9oQArdLBhxLGA/rU4k=";
            fetchSubmodules = true;
          };

          cargoRoot = "src";
          cargoHash = "sha256-mg6qXVz5LvELEEVAkaXVQBR4AtLV0uuFbhgAWNcSq5I=";

          patchPhase = ''
            patchShebangs third_party/mpv
          '';

          buildPhase = ''
            runHook preBuild

            cargo run                             \
            --release                             \
            --manifest-path src/xtask/Cargo.toml  \
            -- build --cef-path ${cef}

            runHook postBuild
          '';

          installPhase = ''
            runHook preInstall

            appDir="$out/lib/jellium-desktop"
            mkdir -p "$appDir" "$out/bin"

            install -Dm755 build/libmpv.so.2 "$appDir/libmpv.so.2"
            install -Dm755 build/jellium-desktop "$appDir/jellium-desktop"
            install -Dm644 resources/linux/net.nullsum.JelliumDesktop.desktop \
                            "$out/share/applications/net.nullsum.JelliumDesktop.desktop"
            install -Dm644 resources/linux/net.nullsum.JelliumDesktop.metainfo.xml \
                            "$out/share/metainfo/net.nullsum.JelliumDesktop.metainfo.xml"
            install -Dm644 resources/linux/net.nullsum.JelliumDesktop.svg \
                            "$out/share/icons/hicolor/scalable/apps/net.nullsum.JelliumDesktop.svg"

            # Currently CEF GPU compositing leads to app crash right after launch
            makeWrapper "$appDir/jellium-desktop" "$out/bin/jellium-desktop" \
              --set CEF_PATH "${cef}" \
              --prefix LD_LIBRARY_PATH : "$appDir:${cef}" \
              --add-flags "--disable-gpu-compositing" \
              --add-flags "--platform-paint shm" \
              --add-flags "--platform wayland"

            runHook postInstall
          '';

          doCheck = false;
          autoPatchelfIgnoreMissingDeps = [
            "libcef.so"
          ];

          nativeBuildInputs = [
            pkg-config
            meson
            ninja
            cmake
            python3
            llvmPackages.clang
            autoPatchelfHook
            makeWrapper
            wayland-scanner
          ];

          buildInputs = [
            alsa-lib
            cef
            curl
            ffmpeg
            lcms2
            libGL
            libarchive
            libass
            libcdio
            libcdio-paranoia
            libdisplay-info
            libdrm
            libgbm
            libjpeg_turbo
            libplacebo
            libuchardet
            libva
            libx11
            libxcb
            libxext
            libxfixes
            libxkbcommon
            libxpresent
            libxrandr
            libxscrnsaver
            lua
            mujs
            nv-codec-headers-12
            pipewire
            pulseaudio
            rubberband
            vulkan-headers
            vulkan-loader
            wayland
            wayland-protocols
            zimg
          ];

          meta = {
            description = "Unofficial desktop client for Jellyfin";
            homepage = "https://github.com/andrewrabert/jellium-desktop";
            license = lib.licenses.gpl2Only;
            platforms = lib.platforms.linux;
            mainProgram = "jellium-desktop";
          };
        };
    in
    {
      packages.jellium-desktop = pkgs.callPackage jellium-desktop { };
    };
}
