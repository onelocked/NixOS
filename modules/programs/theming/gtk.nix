{
  m.desktop =
    {
      lib,
      pkgs,
      config,
      self',
      ...
    }:
    let
      cfg = config.custom.gtk;
      ini = (pkgs.formats.iniWithGlobalSection { }).generate;

      gtk-common = {
        gtk-theme-name = cfg.theme.name;
        gtk-icon-theme-name = cfg.icons.name;
        gtk-cursor-theme-name = cfg.cursor.name;
        gtk-cursor-theme-size = cfg.cursor.size;
        gtk-font-name = with cfg.font; "${name} ${size}";
      };

      gtk2-3-common = {
        gtk-toolbar-style = "GTK_TOOLBAR_ICONS";
        gtk-toolbar-icon-size = "GTK_ICON_SIZE_LARGE_TOOLBAR";
        gtk-button-images = 0;
        gtk-menu-images = 0;
        gtk-enable-event-sounds = 1;
        gtk-enable-input-feedback-sounds = 0;
        gtk-xft-antialias = 1;
        gtk-xft-hinting = 1;
        gtk-xft-hintstyle = "hintslight";
        gtk-xft-rgba = "rgb";
      };

      gtk3-4-common.gtk-application-prefer-dark-theme = 1;
    in
    {
      config = lib.mkIf cfg.enable (
        {
          "${cfg.cursor.name}".source = "${cfg.cursor.package}/share/icons/${cfg.cursor.name}";
          "default/index.theme".text = ''
            [Icon Theme]
            Name=Default
            Comment=Default Cursor Theme
            Inherits=${cfg.cursor.name}
          '';
        }
        |> (cursorFiles: {
          hj.packages = with cfg; [
            theme.package
            cursor.package
            icons.package
          ];

          hj.environment.sessionVariables = {
            XCURSOR_SIZE = cfg.cursor.size;
            XCURSOR_THEME = cfg.cursor.name;
          };

          hj.xdg.config.files = {
            "xsettingsd/xsettingsd.conf".text =
              let
                formatValue = v: if builtins.isString v then ''"${v}"'' else toString v;
              in
              {
                "Net/ThemeName" = cfg.theme.name;
                "Net/IconThemeName" = cfg.icons.name;
                "Gtk/CursorThemeName" = cfg.cursor.name;
                "Net/EnableEventSounds" = gtk2-3-common.gtk-enable-event-sounds;
                "EnableInputFeedbackSounds" = gtk2-3-common.gtk-enable-input-feedback-sounds;
                "Xft/Antialias" = gtk2-3-common.gtk-xft-antialias;
                "Xft/Hinting" = gtk2-3-common.gtk-xft-hinting;
                "Xft/HintStyle" = gtk2-3-common.gtk-xft-hintstyle;
                "Xft/RGBA" = gtk2-3-common.gtk-xft-rgba;
              }
              |> lib.mapAttrsToList (k: v: "${k} ${formatValue v}")
              |> builtins.concatStringsSep "\n"
              |> (s: s + "\n");
          }
          // (
            {
              "4.0" = gtk-common // gtk3-4-common;
              "3.0" = gtk-common // gtk2-3-common // gtk3-4-common;
              "2.0" = gtk-common // gtk2-3-common;
            }
            |> lib.mapAttrsToList (
              version: settings:
              [
                (lib.nameValuePair (if version == "2.0" then "gtk-2.0/gtkrc" else "gtk-${version}/settings.ini") {
                  source = ini "gtkrc-${version}" (
                    if version == "2.0" then { globalSection = settings; } else { sections."Settings" = settings; }
                  );
                })
              ]
              ++ lib.optional (cfg.theme.css != "") (
                lib.nameValuePair "gtk-${version}/gtk.css" { text = cfg.theme.css; }
              )
            )
            |> lib.flatten
            |> builtins.listToAttrs
          );

          hj.xdg.data.files = lib.mapAttrs' (k: v: lib.nameValuePair "icons/${k}" v) cursorFiles;

          hj.files = (lib.mapAttrs' (k: v: lib.nameValuePair ".icons/${k}" v) cursorFiles) // {
            ".Xresources".text = ''
              Xcursor.theme = ${cfg.cursor.name};
              Xcursor.size = ${cfg.cursor.size};
            '';

            ".xprofile".text = /* bash */ ''
              if [ -e "$HOME/.profile" ]; then
                . "$HOME/.profile"
              fi

              # If there are any running services from a previous session.
              # Need to run this in xprofile because the NixOS xsession
              # script starts up graphical-session.target.
              systemctl --user stop graphical-session.target graphical-session-pre.target

              ${lib.getExe pkgs.xsetroot} -xcf ${cfg.cursor.package}/share/icons/${cfg.cursor.name}/cursors/left_ptr ${cfg.cursor.size}

              export HM_XPROFILE_SOURCED=1
            '';
          };

          programs.dconf = {
            enable = true;

            profiles.user.databases = [
              {
                settings = {
                  # disable dconf first use warning
                  "ca/desrt/dconf-editor" = {
                    show-warning = false;
                  };
                  # gtk related settings
                  "org/gnome/desktop/interface" = {
                    gtk-theme = cfg.theme.name;
                    icon-theme = cfg.icons.name;
                    cursor-theme = cfg.cursor.name;
                    cursor-size = cfg.cursor.size;
                    color-scheme = "prefer-dark"; # set dark theme for gtk 4
                    # disable middle click paste
                    gtk-enable-primary-paste = false;
                  };
                };
              }
            ];
          };
        })
      );

      options.custom.gtk = {
        enable = lib.mkEnableOption { } // {
          default = true;
        };

        theme = {
          name = lib.mkOption {
            description = "GTK Theme";
            type = lib.types.str;
            default = "adw-gtk3-dark";
          };

          css = lib.mkOption {
            type = with lib.types; nullOr lines;
            default = "";
            description = "Raw css content";
          };

          package = lib.mkOption {
            description = "GTK Theme package";
            type = lib.types.nullOr lib.types.package;
            default = pkgs.adw-gtk3;
          };
        };

        icons = {
          name = lib.mkOption {
            description = "GTK Icon theme";
            type = lib.types.str;
            default = "Papirus-Dark";
          };

          package = lib.mkOption {
            description = "GTK Icon theme package";
            type = lib.types.nullOr lib.types.package;
            default = pkgs.papirus-icon-theme;
          };
        };

        cursor = {
          name = lib.mkOption {
            description = "Cursor theme";
            type = lib.types.str;
            default = "Bibata-Modern-Ice";
          };

          size = lib.mkOption {
            description = "Cursor size";
            type = lib.types.int;
            default = 24;
            apply = toString;
          };

          package = lib.mkOption {
            description = "Cursor theme package";
            type = lib.types.nullOr lib.types.package;
            default = pkgs.bibata-cursors;
          };
        };

        font = {
          name = lib.mkOption {
            description = "Font name";
            type = lib.types.str;
            default = config.fonts.fontconfig.defaultFonts.sansSerif |> lib.head;
          };

          size = lib.mkOption {
            description = "Font size";
            type = lib.types.int;
            default = 14;
            apply = toString;
          };

          package = lib.mkOption {
            description = "Font package";
            type = lib.types.nullOr lib.types.package;
            default = self'.legacyPackages.apple-font;
          };
        };
      };
    };
  perSystem =
    { pkgs, ... }:
    {
      legacyPackages = {
        ClassicPlatinumStreamlined = pkgs.stdenvNoCC.mkDerivation (finalAttrs: {
          name = "ClassicPlatinumStreamlined";
          src = fetchTarball {
            url = "https://s3.onelock.org/download/ClassicPlatinumStreamlined.tar.gz";
            sha256 = "0ygs7zwndc1cadjvs6lvl3pvcl5agk9an61sc4g5s6iz9nnin0dr";
          };
          dontBuild = true;
          dontConfigure = true;
          installPhase = ''
            mkdir -p $out/share/themes/
            cp -r . $out/share/themes/${finalAttrs.name}/
          '';
        });
      };
    };
}
