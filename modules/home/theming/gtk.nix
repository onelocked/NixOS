{ lib, ... }:
{
  flake.modules.nixos.gtk =
    { config, ... }:
    let
      gtkCfg = config.custom.gtk;
      toIni = lib.generators.toINI {
        mkKeyValue =
          key: value:
          let
            value' = if lib.isBool value then lib.boolToString value else toString value;
          in
          "${lib.escape [ "=" ] key}=${value'}";
      };
      gtkIni = toIni {
        Settings = {
          gtk-theme-name = gtkCfg.theme.name;
          gtk-icon-theme-name = config.custom.gtk.iconTheme.name;
          gtk-application-prefer-dark-theme = 1;
          gtk-error-bell = 0;
        };
      };
    in
    {
      hj.packages = with config.custom.gtk; [
        theme.package
        iconTheme.package
      ];
      environment = {
        etc = {
          "xdg/gtk-3.0/settings.ini".text = gtkIni;
          "xdg/gtk-4.0/settings.ini".text = gtkIni;
          "xdg/gtk-2.0/gtkrc".text = ''
            gtk-icon-theme-name = "${config.custom.gtk.iconTheme.name}";
            gtk-theme-name = "${gtkCfg.theme.name}";
          '';
        };

        sessionVariables = {
          GTK2_RC_FILES = "/etc/xdg/gtk-2.0/gtkrc";
        };
      };

      programs.dconf = {
        enable = true;

        # custom option, the default nesting is horrendous
        profiles.user.databases = [
          {
            settings = lib.mkMerge [
              {
                # disable dconf first use warning
                "ca/desrt/dconf-editor" = {
                  show-warning = false;
                };
                # gtk related settings
                "org/gnome/desktop/interface" = {
                  color-scheme = "prefer-dark"; # set dark theme for gtk 4
                  cursor-theme = gtkCfg.cursor.name;
                  cursor-size = lib.gvariant.mkUint32 gtkCfg.cursor.size;
                  gtk-theme = gtkCfg.theme.name;
                  icon-theme = gtkCfg.iconTheme.name;
                  # disable middle click paste
                  gtk-enable-primary-paste = false;
                };
              }
              config.custom.dconf.settings
            ];
          }
        ];
      };
    };
  flake.modules.nixos.default =
    { pkgs, ... }:
    let
      inherit (lib) mkOption types literalExpression;
    in
    {
      options.custom = {
        # type referenced from nixpkgs:
        # https://github.com/NixOS/nixpkgs/blob/554be6495561ff07b6c724047bdd7e0716aa7b46/nixos/modules/programs/dconf.nix#L121C9-L134C11
        dconf.settings = mkOption {
          type = types.attrs;
          default = { };
          description = "An attrset used to generate dconf keyfile.";
          example = literalExpression ''
            with lib.gvariant;
            {
              "com/raggesilver/BlackBox" = {
                scrollback-lines = mkUint32 10000;
                theme-dark = "Tomorrow Night";
              };
            }
          '';
        };

        gtk = {
          theme = {
            package = lib.mkOption {
              type = lib.types.package;
              default = pkgs.adw-gtk3;
              description = "Package providing the theme.";
            };

            name = lib.mkOption {
              type = lib.types.str;
              default = "adw-gtk3-dark";
              description = "The name of the theme within the package.";
            };
          };
          iconTheme = {
            package = lib.mkOption {
              type = lib.types.package;
              default = pkgs.papirus-icon-theme;
              description = "Package providing the icon theme.";
            };

            name = lib.mkOption {
              type = lib.types.str;
              default = "Papirus-Dark";
              description = "The name of the icon theme within the package.";
            };
          };
          font = {
            package = lib.mkOption {
              type = lib.types.package;
              default = pkgs.apple-font;
              description = "Package providing the font";
            };

            name = lib.mkOption {
              type = lib.types.str;
              default = "SF Pro Display";
              description = "The family name of the font within the package.";
            };

            size = lib.mkOption {
              type = lib.types.number;
              default = 14;
              description = "The size of the font.";
            };
          };
        };
      };
    };

}
