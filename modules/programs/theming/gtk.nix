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
      cfg = config.forte.gtk;
    in
    {
      config = lib.mkIf cfg.enable {
        hj.packages = with cfg; [
          theme.package
          cursor.package
          icons.package
        ];
        hj.environment.sessionVariables = {
          XCURSOR_SIZE = cfg.cursor.size;
          XCURSOR_THEME = cfg.cursor.name;
        };
        programs.dconf = {
          enable = true;
          profiles.user.databases = [
            {
              settings = {
                "ca/desrt/dconf-editor".show-warning = false;
                "org/gnome/desktop/thumbnailers".disable-all = true;
                "org/gnome/desktop/screen-time-limits" = {
                  history-enabled = false;
                };
                "org/gnome/desktop/media-handling" = {
                  automount = false;
                  automount-open = false;
                  autorun-never = true;
                };
                "org/gnome/desktop/interface" =
                  with cfg;
                  let
                    mkFont = name: "${name} ${font.size}";
                  in
                  {
                    gtk-theme = theme.name;
                    icon-theme = icons.name;
                    cursor-theme = cursor.name;
                    cursor-size = cursor.size;
                    color-scheme = "prefer-dark";
                    font-name = mkFont font.serif;
                    document-font-name = mkFont font.sansSerif;
                    monospace-font-name = mkFont font.mono;
                    font-antialiasing = "rgba";
                    font-hinting = "full";
                    text-scaling-factor = 1.0;
                    gtk-enable-primary-paste = false;
                    overlay-scrolling = false;
                  };
              };
            }
          ];
        };
      };

      options.forte.gtk = {
        enable = lib.mkEnableOption { } // {
          default = true;
        };

        theme = {
          name = lib.mkOption {
            description = "GTK Theme";
            type = lib.types.str;
            default = "ClassicPlatinumStreamlined";
          };

          css = lib.mkOption {
            type = with lib.types; nullOr lines;
            default = "";
            description = "Raw css content";
          };

          package = lib.mkOption {
            description = "GTK Theme package";
            type = lib.types.nullOr lib.types.package;
            default = self'.legacyPackages.ClassicPlatinumStreamlined;
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
          serif = lib.mkOption {
            description = "Font name";
            type = lib.types.str;
            default = config.fonts.fontconfig.defaultFonts.serif |> lib.head;
          };
          mono = lib.mkOption {
            description = "Monospace font";
            type = lib.types.str;
            default = config.fonts.fontconfig.defaultFonts.monospace |> lib.head;
          };
          sansSerif = lib.mkOption {
            description = "Sans Serif font";
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
