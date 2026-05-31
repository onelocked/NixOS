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
      cursor = config.forte.cursor;
    in
    {
      config = lib.mkIf cfg.enable {
        hj.packages = with cfg; [
          theme.package
          icons.package
        ];

        hj.xdg.config.files = lib.optionalAttrs (cfg.theme.css != "") (
          [
            "4.0"
            "3.0"
          ]
          |> map (version: lib.nameValuePair "gtk-${version}/gtk.css" { text = cfg.theme.css; })
          |> builtins.listToAttrs
        );

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
            default = "RetroismIcons";
          };

          package = lib.mkOption {
            description = "GTK Icon theme package";
            type = lib.types.nullOr lib.types.package;
            default = self'.legacyPackages.RetroismIcons;
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

        RetroismIcons = pkgs.stdenvNoCC.mkDerivation (finalAttrs: {
          name = "RetroismIcons";
          src = fetchTarball {
            url = "https://s3.onelock.org/download/RetroismIcons.tar.gz";
            sha256 = "1sn5fyw0pfjbi1nm5c1f3dwvzp8359i0ij3k0fqj32n5yf09zbxg";
          };
          dontBuild = true;
          dontConfigure = true;
          dontFixup = true;
          installPhase = ''
            mkdir -p $out/share/icons/${finalAttrs.name}
            cp -r . $out/share/icons/${finalAttrs.name}
          '';
        });
      };
    };
}
