{ inputs, ... }:
{
  flake.homeModules.zen-browser =
    { pkgs, ... }:
    {
      imports = [ inputs.zen-browser.homeModules.twilight ];
      programs.zen-browser =
        let
          mkLockedAttrs = builtins.mapAttrs (
            _: value: {
              Value = value;
              Status = "locked";
            }
          );
        in
        {
          enable = true;
          suppressXdgMigrationWarning = true;
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
              "media.hardware-video-decoding.force-enabled" = true; # default = false
              "media.rdd-ffmpeg.enabled" = true; # default = true
              "media.av1.enabled" = true; # default = true
              "gfx.x11-egl.force-enabled" = false; # default = false
              "widget.dmabuf.force-enabled" = true; # default = false

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
              "network.socket.ip_addr_any.disabled" = true; # disallow bind to 0.0.0.0

              "widget.use-xdg-desktop-portal.file-picker" = 1;

              "mousebutton.4th.enabled" = false;
              "mousebutton.5th.enabled" = false;
              "zen.welcome-screen.seen" = true;
              "zen.view.experimental-no-window-controls" = true;
              "zen.view.compact.hide-toolbar" = false;
              "zen.view.compact.hide-tabbar" = true;
              "middlemouse.paste" = false;

            };
            ExtensionSettings = {
              #Bitwarden Password Manager
              "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
                install_url = "https://addons.mozilla.org/firefox/downloads/file/4493940/bitwarden_password_manager-latest.xpi";
                installation_mode = "force_installed";
              };
              #uBlock Origin
              "uBlock0@raymondhill.net" = {
                install_url = "https://addons.mozilla.org/firefox/downloads/file/4458450/ublock_origin-latest.xpi";
                installation_mode = "force_installed";
              };
              #Karakeep (Hoarder)
              "addon@karakeep.app" = {
                install_url = "https://addons.mozilla.org/firefox/downloads/file/4477863/karakeep-latest.xpi";
                installation_mode = "force_installed";
              };
              "booru-extension@onelock.org" = {
                install_url = "https://s3.onelock.org/download/extensions/booru-extension.xpi";
                installation_mode = "force_installed";
              };
            };
          };
          profiles.default = {
            mods = [
              "ae7868dc-1fa1-469e-8b89-a5edf7ab1f24" # Load Bar
              "e122b5d9-d385-4bf8-9971-e137809097d0" # No Top Sites
              "e51b85e6-cef5-45d4-9fff-6986637974e1" # smaller zen toast popup
              "b51ff956-6aea-47ab-80c7-d6c047c0d510" # Disable Status Bar
              "ad97bb70-0066-4e42-9b5f-173a5e42c6fc" # SuperPins
              "a6335949-4465-4b71-926c-4a52d34bc9c0" # Better Find Bar
            ];
            settings = {
              "mousebutton.4th.enabled" = false;
              "mousebutton.5th.enabled" = false;
              "zen.welcome-screen.seen" = true;
              "zen.view.experimental-no-window-controls" = true;
              "zen.view.compact.hide-toolbar" = false;
              "zen.view.compact.hide-tabbar" = true;
              "middlemouse.paste" = false;
            };
          };
        };
      xdg.mimeApps =
        let
          zen-browser-pkg = inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.twilight;
          associations = builtins.listToAttrs (
            map
              (name: {
                inherit name;
                value = zen-browser-pkg.meta.desktopFile;
              })
              [
                "application/x-extension-shtml"
                "application/x-extension-xhtml"
                "application/x-extension-html"
                "application/x-extension-xht"
                "application/x-extension-htm"
                "x-scheme-handler/unknown"
                "x-scheme-handler/mailto"
                "x-scheme-handler/chrome"
                "x-scheme-handler/about"
                "x-scheme-handler/https"
                "x-scheme-handler/http"
                "application/xhtml+xml"
                "application/json"
                "text/plain"
                "text/html"
              ]
          );
        in
        {
          associations.added = associations;
          defaultApplications = associations;
        };
    };
}
