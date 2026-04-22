{ inputs, lib, ... }:
{
  ff.zen-browser = {
    url = "github:0xc000022070/zen-browser-flake";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  m.zen-browser =
    { pkgs, config, ... }:
    let
      cfg = config.custom.programs.zen-browser;

      mkLockedAttrs = builtins.mapAttrs (
        _: value: {
          Value = value;
          Status = "locked";
        }
      );

      unwrapped =
        inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.twilight-unwrapped.override
          {
            inherit (cfg) policies;
          };

      wrapped = pkgs.wrapFirefox unwrapped {
        inherit (cfg) extraPrefs nativeMessagingHosts;
      };

      mkUserJs =
        settings:
        settings
        |> lib.mapAttrsToList (name: value: ''user_pref("${name}", ${builtins.toJSON value});'')
        |> lib.concatStringsSep "\n";

      profilesCfg = cfg.profiles;

      modsActivationScript =
        profileName: profile:
        let
          inherit (profile) mods;
          profilePath = "${config.hj.xdg.config.directory}/zen/${profile.path}";
        in
        pkgs.writeShellScript "zen-mods-update-${profileName}" ''
          set -uo pipefail
          export PATH=${
            lib.makeBinPath [
              pkgs.jq
              pkgs.curl
              pkgs.util-linux
            ]
          }:$PATH

          THEMES_FILE="${profilePath}/zen-themes.json"
          MODS="${lib.concatStringsSep " " mods}"
          BASE_DIR="${profilePath}"
          MANAGED_FILE="$BASE_DIR/zen-mods-nix-managed.json"
          LOCK_FILE="$BASE_DIR/.zen-mods.lock"

          mkdir -p "$BASE_DIR/chrome/zen-themes"

          exec 9>"$LOCK_FILE"
          if ! flock -n 9; then
            echo "Another zen-mods update in progress, exiting"
            exit 0
          fi

          [ -f "$THEMES_FILE" ] || echo '{}' > "$THEMES_FILE"

          update_json() {
            local tmp
            tmp=$(mktemp)
            if jq "$@" "$THEMES_FILE" > "$tmp" && jq empty "$tmp" 2>/dev/null; then
              mv "$tmp" "$THEMES_FILE"
              return 0
            fi
            rm -f "$tmp"
            return 1
          }

          wait_for_network() {
            local i delay
            for i in 1 2 3 4 5 6; do
              if curl -sfI --max-time 5 --connect-timeout 3 \
                https://raw.githubusercontent.com >/dev/null 2>&1; then
                return 0
              fi
              delay=$((i * 3))
              echo "Network check failed ($i/6), retrying in ''${delay}s..."
              sleep "$delay"
            done
            return 1
          }

          if [ -f "$MANAGED_FILE" ]; then
            CURRENT_MANAGED=$(jq -r '.[]' "$MANAGED_FILE" 2>/dev/null || echo "")
          else
            CURRENT_MANAGED=""
          fi

          for uuid in $CURRENT_MANAGED; do
            if [[ " $MODS " != *" $uuid "* ]]; then
              update_json --arg u "$uuid" 'del(.[$u])' || true
              rm -rf "$BASE_DIR/chrome/zen-themes/$uuid"
              echo "Removed mod $uuid"
            fi
          done

          needs_fetch=0
          for mod_uuid in $MODS; do
            MOD_DIR="$BASE_DIR/chrome/zen-themes/$mod_uuid"
            has_entry=$(jq --arg u "$mod_uuid" 'has($u)' "$THEMES_FILE" 2>/dev/null || echo false)
            if [ ! -d "$MOD_DIR" ] || [ "$has_entry" != "true" ]; then
              needs_fetch=1
              break
            fi
          done

          network_ok=1
          if [ "$needs_fetch" = "1" ] && ! wait_for_network; then
            echo "Network unavailable, skipping fetch (regenerating CSS from cache)"
            network_ok=0
          fi

          if [ "$network_ok" = "1" ]; then
            for mod_uuid in $MODS; do
              MOD_DIR="$BASE_DIR/chrome/zen-themes/$mod_uuid"
              has_entry=$(jq --arg u "$mod_uuid" 'has($u)' "$THEMES_FILE" 2>/dev/null || echo false)
              if [ -d "$MOD_DIR" ] && [ "$has_entry" = "true" ]; then
                continue
              fi

              THEME_URL="https://raw.githubusercontent.com/zen-browser/theme-store/main/themes/$mod_uuid/theme.json"
              echo "Fetching mod $mod_uuid"

              THEME_JSON=$(curl -sfL --retry 3 --retry-delay 2 --retry-connrefused \
                --max-time 30 "$THEME_URL" || true)
              if [ -z "$THEME_JSON" ] || ! echo "$THEME_JSON" | jq empty 2>/dev/null; then
                echo "Failed to fetch theme for mod $mod_uuid, skipping"
                continue
              fi

              if ! update_json --arg uuid "$mod_uuid" --argjson theme "$THEME_JSON" \
                '.[$uuid] = $theme'; then
                echo "Failed to update themes.json for $mod_uuid, skipping"
                continue
              fi

              mkdir -p "$MOD_DIR"
              for file in chrome.css preferences.json readme.md; do
                curl -sfL --retry 3 --retry-delay 2 --retry-connrefused --max-time 30 \
                  "https://raw.githubusercontent.com/zen-browser/theme-store/main/themes/$mod_uuid/$file" \
                  -o "$MOD_DIR/$file" || true
              done
            done
          fi

          jq -R 'split(" ") | map(select(length > 0))' <<<"$MODS" > "$MANAGED_FILE"

          ZEN_THEMES_CSS="$BASE_DIR/chrome/zen-themes.css"
          cat > "$ZEN_THEMES_CSS" <<'EOFCSS'
          /* Zen Mods - Generated by NixOS activation.
           * DO NOT EDIT THIS FILE DIRECTLY!
           * Your changes will be overwritten.
           */
          EOFCSS

          ENABLED_MODS=$(jq -r 'to_entries[] | select(.value.enabled == null or .value.enabled == true) | .key' "$THEMES_FILE")

          for mod_uuid in $ENABLED_MODS; do
            MOD_CSS="$BASE_DIR/chrome/zen-themes/$mod_uuid/chrome.css"
            if [ -f "$MOD_CSS" ]; then
              MOD_INFO=$(jq -r --arg u "$mod_uuid" \
                '.[$u] | "/* Name: \(.name) */\n/* Description: \(.description) */\n/* Author: @\(.author) */"' \
                "$THEMES_FILE")
              echo "$MOD_INFO" >> "$ZEN_THEMES_CSS"
              cat "$MOD_CSS" >> "$ZEN_THEMES_CSS"
              echo "" >> "$ZEN_THEMES_CSS"
            fi
          done

          echo "/* End of Zen Mods */" >> "$ZEN_THEMES_CSS"
        '';
    in
    {
      custom.programs.zen-browser = {
        setAsDefaultBrowser = true;
        policies = {
          AutofillAddressEnabled = false;
          AutofillCreditCardEnabled = false;
          DisableAppUpdate = true;
          DisableFeedbackCommands = true;
          DisableFirefoxStudies = true;
          DisablePocket = true;
          DisableTelemetry = true;
          DontCheckDefaultBrowser = true;
          NoDefaultBookmarks = true;
          OfferToSaveLogins = false;
          PrintingEnabled = false;
          TranslateEnabled = false;
          SupportMenu = false;
          HardwareAcceleration = true;
          EnableTrackingProtection = {
            Value = true;
            Locked = true;
            Cryptomining = true;
            Fingerprinting = true;
          };
          Preferences = mkLockedAttrs {
            "media.hardware-video-decoding.force-enabled" = true;
            "media.rdd-ffmpeg.enabled" = true;
            "media.av1.enabled" = true;
            "gfx.x11-egl.force-enabled" = false;
            "widget.dmabuf.force-enabled" = true;

            "browser.tabs.warnOnClose" = false;
            "browser.aboutConfig.showWarning" = false;

            "xpinstall.signatures.required" = false;
            "toolkit.legacyUserProfileCustomizations.stylesheets" = true;

            "gfx.webrender.all" = true;

            "privacy.resistFingerprinting" = true;
            "privacy.resistFingerprinting.randomization.canvas.use_siphash" = true;
            "privacy.resistFingerprinting.randomization.daily_reset.enabled" = true;
            "privacy.resistFingerprinting.randomization.daily_reset.private.enabled" = true;
            "privacy.resistFingerprinting.block_mozAddonManager" = true;
            "privacy.spoof_english" = 1;

            "network.http.http3.enabled" = true;
            "network.socket.ip_addr_any.disabled" = true;

            "widget.use-xdg-desktop-portal.file-picker" = 1;

            "mousebutton.4th.enabled" = false;
            "mousebutton.5th.enabled" = false;
            "zen.welcome-screen.seen" = true;
            "zen.view.experimental-no-window-controls" = true;
            "zen.view.compact.hide-toolbar" = false;
            "zen.view.compact.hide-tabbar" = true;
            "middlemouse.paste" = false;
          };
          ExtensionSettings =
            {
              "{446900e4-71c2-419f-a6a7-df9c091e268b}" = "bitwarden-password-manager";
              "uBlock0@raymondhill.net" = "ublock-origin";
              "addon@karakeep.app" = "karakeep";
            }
            |> lib.mapAttrs (
              _: slug: {
                install_url = "https://addons.mozilla.org/firefox/downloads/latest/${slug}/latest.xpi";
                installation_mode = "force_installed";
              }
            )
            |> (
              amo:
              amo
              // {
                "booru-extension@onelock.org" = {
                  install_url = "https://s3.onelock.org/download/extensions/booru-extension.xpi";
                  installation_mode = "force_installed";
                };
              }
            );
        };
        profiles.default = {
          isDefault = true;
          mods = [
            "ae7868dc-1fa1-469e-8b89-a5edf7ab1f24" # Load Bar
            "e122b5d9-d385-4bf8-9971-e137809097d0" # No Top Sites
            "e51b85e6-cef5-45d4-9fff-6986637974e1" # smaller zen toast popup
            "b51ff956-6aea-47ab-80c7-d6c047c0d510" # Disable Status Bar
            "ad97bb70-0066-4e42-9b5f-173a5e42c6fc" # SuperPins
            "a6335949-4465-4b71-926c-4a52d34bc9c0" # Better Find Bar
          ];
        };
      };

      hj.packages = [ wrapped ];

      hj.files =
        let
          profileValues = lib.attrValues profilesCfg;

          defaultPath = (lib.findFirst (p: p.isDefault) (lib.head profileValues) profileValues).path;

          profileSections =
            profilesCfg
            |> lib.attrNames
            |> lib.imap0 (
              i: name:
              lib.nameValuePair "Profile${toString i}" (
                {
                  Name = name;
                  IsRelative = 1;
                  Path = profilesCfg.${name}.path;
                }
                // lib.optionalAttrs profilesCfg.${name}.isDefault { Default = 1; }
              )
            )
            |> builtins.listToAttrs;

          profilesIni = lib.generators.toINI { } (
            {
              General.StartWithLastProfile = 1;
              Install.Default = defaultPath;
            }
            // profileSections
          );

          userJsFiles =
            profilesCfg
            |> lib.mapAttrs' (
              name: profile:
              lib.nameValuePair ".config/zen/${profile.path}/user.js" {
                text = mkUserJs profile.settings + "\n";
              }
            );
        in
        {
          ".config/zen/profiles.ini".text = profilesIni;
        }
        // userJsFiles;

      xdg.mime = lib.mkIf cfg.setAsDefaultBrowser {
        defaultApplications =
          [
            "application/x-extension-shtml"
            "application/x-extension-xhtml"
            "application/x-extension-html"
            "application/x-extension-xht"
            "application/x-extension-htm"
            "x-scheme-handler/unknown"
            "x-scheme-handler/https"
            "x-scheme-handler/http"
            "application/xhtml+xml"
            "application/json"
            "application/pdf"
            "text/html"
          ]
          |> (mimes: lib.genAttrs mimes (_: [ "zen-twilight.desktop" ]));
      };

      environment.sessionVariables = lib.mkIf cfg.setAsDefaultBrowser {
        BROWSER = "zen-twilight";
      };

      hj.systemd.services =
        profilesCfg
        |> lib.mapAttrsToList (
          name: profile:
          lib.mkIf (profile.mods != [ ]) {
            "zen-profile-${name}" = {
              description = "Update Zen Browser mods for profile '${name}'";
              wantedBy = [ "graphical-session.target" ];
              partOf = [ "graphical-session.target" ];
              after = [ "graphical-session.target" ];
              serviceConfig = {
                Type = "oneshot";
                ExecStart = "${modsActivationScript name profile}";
                RemainAfterExit = true;
              };
            };
          }
        )
        |> lib.mkMerge;
    };

  m.default =
    { lib, ... }:
    {
      options.custom.programs.zen-browser = {
        policies = lib.mkOption {
          type = lib.types.attrs;
          default = { };
          description = "Zen Browser policies.";
        };

        extraPrefs = lib.mkOption {
          type = lib.types.str;
          default = "";
          description = "Extra preferences to include.";
        };

        nativeMessagingHosts = lib.mkOption {
          type = lib.types.listOf lib.types.package;
          default = [ ];
          description = "Native messaging hosts.";
        };

        setAsDefaultBrowser = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Set Zen Browser as default browser.";
        };

        profiles = lib.mkOption {
          default = { };
          type = lib.types.attrsOf (
            lib.types.submodule (
              { name, ... }:
              {
                options = {
                  path = lib.mkOption {
                    type = lib.types.str;
                    default = name;
                    description = "Profile directory name.";
                  };

                  isDefault = lib.mkOption {
                    type = lib.types.bool;
                    default = false;
                    description = "Whether this is the default profile.";
                  };

                  settings = lib.mkOption {
                    type = lib.types.attrs;
                    default = { };
                    description = "Profile settings (written to user.js).";
                  };

                  mods = lib.mkOption {
                    type = lib.types.listOf lib.types.str;
                    default = [ ];
                    description = "List of mod UUIDs from Zen theme store.";
                  };
                };
              }
            )
          );
          description = "Zen Browser profiles.";
        };
      };
    };
}
