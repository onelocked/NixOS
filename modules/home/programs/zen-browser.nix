{ inputs, ... }:
{
  flake.modules.homeManager.zen-browser = {
    imports = [ inputs.zen-browser.homeModules.twilight ];
    programs.zen-browser = {
      enable = true;
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
            #VA-API
            "media.hardware-video-decoding.force-enabled" = true; # default = false
            "media.rdd-ffmpeg.enabled" = true; # default = true
            "media.av1.enabled" = true; # default = true
            "gfx.x11-egl.force-enabled" = false; # default = false
            "widget.dmabuf.force-enabled" = true; # default = false

            "browser.tabs.warnOnClose" = false;
            "browser.aboutConfig.showWarning" = false;

            "xpinstall.signatures.required" = false;
            "toolkit.legacyUserProfileCustomizations.stylesheets" = true;

            "zen.view.experimental-no-window-controls" = true;
            "zen.view.compact.hide-toolbar" = false;
            "zen.view.compact.hide-tabbar" = true;

            "gfx.webrender.all" = true;

            "mousebutton.4th.enabled" = false;
            "mousebutton.5th.enabled" = false;

            "privacy.resistFingerprinting" = true;
            "privacy.resistFingerprinting.randomization.canvas.use_siphash" = true;
            "privacy.resistFingerprinting.randomization.daily_reset.enabled" = true;
            "privacy.resistFingerprinting.randomization.daily_reset.private.enabled" = true;
            "privacy.resistFingerprinting.block_mozAddonManager" = true;
            "privacy.spoof_english" = 1;

            "network.http.http3.enabled" = true;
            "network.socket.ip_addr_any.disabled" = true; # disallow bind to 0.0.0.0

            "widget.use-xdg-desktop-portal.file-picker" = 1;

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
          };
        };
    };
    xdg.mimeApps =
      let
        zen-browser-pkg = inputs.zen-browser.homeModules.twilight;
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
