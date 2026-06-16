{ inputs, ... }:
{
  ff = {
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "";
    };
    theme-store = {
      url = "github:zen-browser/theme-store";
      flake = false;
    };
  };

  exo.mods.desktop =
    { lib, ... }:
    {
      forte.zen-browser = {
        enable = true;
        setAsDefaultBrowser = true;
        policies =
          let
            mkLockedAttrs = builtins.mapAttrs (
              _: value: {
                Value = value;
                Status = "locked";
              }
            );
          in
          {
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
          mods = {
            "Load Bar" = "ae7868dc-1fa1-469e-8b89-a5edf7ab1f24";
            "No Top Sites" = "e122b5d9-d385-4bf8-9971-e137809097d0";
            "Smaller Zen Toast Popup" = "e51b85e6-cef5-45d4-9fff-6986637974e1";
            "Disable Status Bar" = "b51ff956-6aea-47ab-80c7-d6c047c0d510";
            "SuperPins" = "ad97bb70-0066-4e42-9b5f-173a5e42c6fc";
            "Better Find Bar" = "a6335949-4465-4b71-926c-4a52d34bc9c0";
          };
        };
      };
    };

  exo.skeleton =
    {
      inputs',
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.forte.zen-browser;

      unwrapped = inputs'.zen-browser.packages.twilight-unwrapped.override { inherit (cfg) policies; };

      wrapped = pkgs.wrapFirefox unwrapped { inherit (cfg) extraPrefs nativeMessagingHosts; };

      mkUserJs =
        settings:
        settings
        |> lib.mapAttrsToList (name: value: ''user_pref("${name}", ${builtins.toJSON value});'')
        |> lib.concatStringsSep "\n";

      profilesCfg = cfg.profiles;

      mkModData =
        uuid:
        let
          themePath = "${inputs.theme-store}/themes/${uuid}";
        in
        {
          inherit uuid themePath;
          themeJson = builtins.fromJSON (builtins.readFile "${themePath}/theme.json");
        };

      mkThemesJson =
        mods: mods |> map (m: lib.nameValuePair m.uuid m.themeJson) |> lib.listToAttrs |> builtins.toJSON;

      mkThemesCss =
        mods:
        let
          section = m: ''
            /* Name: ${m.themeJson.name or ""} */
            /* Description: ${m.themeJson.description or ""} */
            /* Author: @${m.themeJson.author or ""} */
            ${builtins.readFile "${m.themePath}/chrome.css"}
          '';
        in
        ''
          /* Zen Mods - Generated by NixOS.
           * DO NOT EDIT THIS FILE DIRECTLY!
           * Your changes will be overwritten.
           */
        ''
        + lib.concatMapStrings section mods
        + "/* End of Zen Mods */\n";
    in
    {

      config = lib.mkIf (cfg.enable) {
        hj.packages = [ cfg.package ];
        hj.xdg.config.files = lib.mkIf (profilesCfg != { }) (
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
            userJsFiles =
              profilesCfg
              |> lib.mapAttrs' (
                name: profile:
                lib.nameValuePair "zen/${profile.path}/user.js" {
                  text = mkUserJs profile.settings + "\n";
                }
              );
            modFiles =
              profilesCfg
              |> lib.concatMapAttrs (
                _: profile:
                let
                  mods = map mkModData (lib.attrValues profile.mods);
                  base = "zen/${profile.path}/chrome";
                  perMod = lib.concatMap (
                    m:
                    [
                      {
                        name = "${base}/zen-themes/${m.uuid}/chrome.css";
                        value.source = "${m.themePath}/chrome.css";
                      }
                    ]
                    ++ lib.optional (builtins.pathExists "${m.themePath}/preferences.json") {
                      name = "${base}/zen-themes/${m.uuid}/preferences.json";
                      value.source = "${m.themePath}/preferences.json";
                    }
                  ) mods;
                  aggregate = lib.optionalAttrs (mods != [ ]) {
                    "${base}/zen-themes.json".text = mkThemesJson mods;
                    "${base}/zen-themes.css".text = mkThemesCss mods;
                  };
                in
                lib.listToAttrs perMod // aggregate
              );
          in
          lib.mergeAttrsList [
            {
              "zen/profiles.ini".text = lib.generators.toINI { } (
                {
                  General.StartWithLastProfile = 1;
                  Install.Default = defaultPath;
                }
                // profileSections
              );
            }
            userJsFiles
            modFiles
          ]
        );

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

        hj.environment.sessionVariables = lib.mkIf cfg.setAsDefaultBrowser { BROWSER = "zen-twilight"; };
        forte.hyprland.lua = {
          window-rules = # lua
            ''
              hl.window_rule({
                name             = "zen-twilight",
                match            = { class = "zen-twilight" },
                workspace        = "name:web",
                fullscreen_state = "0 3",
                opacity          = "1 override",
                no_initial_focus = true,
              })
              hl.window_rule({
                name       = "zen-pip",
                match      = { class = "zen-twilight", title = "Picture-in-Picture" },
                fullscreen = true,
                workspace  = "name:web",
              })
              hl.window_rule({
                name   = "zen-library",
                match  = { class = "zen-twilight", title = "Library" },
                float  = true,
                size   = { 1300, 900 },
                center = true,
              })
            '';
          keybinds = # lua
            ''
              hl.bind("SUPER + B", function()
                  local win = hl.get_window("class:zen-twilight")
                  if win then
                      hl.dispatch(hl.dsp.focus({ window = win }))
                  else
                      hl.dispatch(hl.dsp.exec_raw("zen-twilight"))
                  end
              end)
            '';
        };
      };
      options.forte.zen-browser = {
        enable = lib.mkEnableOption "zen-browser";

        package = lib.mkOption {
          type = lib.types.package;
          default = wrapped;
          description = "The package to use.";
        };

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
                    type = lib.types.attrsOf lib.types.str;
                    default = { };
                    description = "Attrset of mod display name → UUID from Zen theme store.";
                  };
                };
              }
            )
          );
        };
      };
    };
}
