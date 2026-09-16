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
              match            = { class = "wlroots" },
              workspace        = "5",
              opacity          = "1 override",
              idle_inhibit = "focus",
            })
          '';
      };

      options.forte.jellyfin-desktop = {
        enable = lib.mkEnableOption "jellium-desktop" // {
          default = true;
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
      jellium-desktop-unwrapped =
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
          cef = runCommand "cef-jellium-151.3.16" { } ''
            mkdir -p "$out"

            # Jellium Desktop expects a flat structure
            cp -r ${cef-binary}/include "$out"
            cp -r ${cef-binary}/Release/* "$out"
            cp -r ${cef-binary}/Resources/* "$out"

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
            rev = "28f2cf16a1f1b819884dd6a72919ca55bdf9bd73";
            hash = "sha256-cs7wxsX5fHaxVvnsSKjbq+rG//LjkV7592LnThnlPJE=";
            fetchSubmodules = true;
          };

          cargoRoot = "src";
          cargoHash = "sha256-JFFQjOw4Iu6NiQScQqYg/J7XEkLbHCDa+XS12VJJdVI=";

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
              --prefix LD_LIBRARY_PATH : "$appDir:${cef}"
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
      jellium-desktop = pkgs.callPackage jellium-desktop-unwrapped { };
    in
    {
      remotePackages.jellium-desktop = pkgs.symlinkJoin {
        name = "jellium-desktop";
        nativeBuildInputs = [ pkgs.makeWrapper ];
        paths = [ jellium-desktop ];
        postBuild = ''
          rm "$out/bin/jellium-desktop"
          makeWrapper "${pkgs.cage}/bin/cage" "$out/bin/jellium-desktop" \
            --add-flags "-d" \
            --add-flags "--" \
            --add-flags "${jellium-desktop}/bin/jellium-desktop" \
            --add-flags "--platform-paint=dmabuf" \
            --add-flags "--platform=wayland"
        '';
      };
    };
}
