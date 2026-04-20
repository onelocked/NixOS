{ lib, ... }:
{
  m.gtk =
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
      gtkIni =
        {
          Settings = {
            gtk-theme-name = gtkCfg.theme.name;
            gtk-icon-theme-name = gtkCfg.iconTheme.name;
            gtk-application-prefer-dark-theme = 1;
            gtk-error-bell = 0;
          };
        }
        |> toIni;
    in
    {
      hj.packages = with gtkCfg; [
        theme.package
        iconTheme.package
      ];
      hj.xdg.config.files =
        [
          "4.0"
          "3.0"
          "2.0"
        ]
        |> map (version: lib.nameValuePair "gtk-${version}/gtk.css" { text = gtkCfg.theme.css; })
        |> builtins.listToAttrs;

      environment = {
        etc =
          [
            "3.0"
            "4.0"
          ]
          |> map (version: lib.nameValuePair "xdg/gtk-${version}/settings.ini" { text = gtkIni; })
          |> builtins.listToAttrs
          |> (
            x:
            x
            // {
              "xdg/gtk-2.0/gtkrc".text = ''
                gtk-icon-theme-name = "${gtkCfg.iconTheme.name}";
                gtk-theme-name = "${gtkCfg.theme.name}";
              '';
            }
          );
        sessionVariables.GTK2_RC_FILES = "/etc/xdg/gtk-2.0/gtkrc";
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
      custom.gtk.theme.css = # css
        ''
          @define-color accent_color #c5c0ff;
          @define-color accent_bg_color #c5c0ff;
          @define-color accent_fg_color #2a2277;

          @define-color destructive_bg_color #ffb4ab;
          @define-color destructive_fg_color #690005;

          @define-color error_bg_color #ffb4ab;
          @define-color error_fg_color #690005;

          @define-color window_bg_color #131316;
          @define-color window_fg_color #e5e1e6;

          @define-color view_bg_color #131316;
          @define-color view_fg_color #e5e1e6;

          @define-color headerbar_bg_color #131316;
          @define-color headerbar_fg_color #e5e1e6;
          @define-color headerbar_backdrop_color @window_bg_color;

          @define-color popover_bg_color #201f23;
          @define-color popover_fg_color #e5e1e6;

          @define-color card_bg_color #201f23;
          @define-color card_fg_color #e5e1e6;

          @define-color dialog_bg_color #131316;
          @define-color dialog_fg_color #e5e1e6;

          @define-color overview_bg_color #201f23;
          @define-color overview_fg_color #e5e1e6;

          @define-color sidebar_bg_color #201f23;
          @define-color sidebar_fg_color #e5e1e6;
          @define-color sidebar_backdrop_color @window_bg_color;
          @define-color sidebar_border_color @window_bg_color;

          @define-color secondary_sidebar_bg_color #131316;
          @define-color secondary_sidebar_fg_color #e5e1e6;

          /* Backdrop/unfocused states */
          @define-color theme_unfocused_fg_color @window_fg_color;
          @define-color theme_unfocused_text_color @view_fg_color;
          @define-color theme_unfocused_bg_color @window_bg_color;
          @define-color theme_unfocused_base_color @window_bg_color;
          @define-color theme_unfocused_selected_bg_color @accent_bg_color;
          @define-color theme_unfocused_selected_fg_color @accent_fg_color;

          :root {
              --accent-color: #c5c0ff;
              --accent-bg-color: #c5c0ff;
              --accent-fg-color: #2a2277;

              --destructive-bg-color: #ffb4ab;
              --destructive-fg-color: #690005;

              --error-bg-color: #ffb4ab;
              --error-fg-color: #690005;
              --error-color: #ffb4ab;

              --window-bg-color: #131316;
              --window-fg-color: #e5e1e6;

              --view-bg-color: #131316;
              --view-fg-color: #e5e1e6;

              --headerbar-bg-color: #131316;
              --headerbar-fg-color: #e5e1e6;
              --headerbar-backdrop-color: @window_bg_color;

              --popover-bg-color: #201f23;
              --popover-fg-color: #e5e1e6;

              --card-bg-color: #201f23;
              --card-fg-color: #e5e1e6;

              --dialog-bg-color: #131316;
              --dialog-fg-color: #e5e1e6;

              --overview-bg-color: #201f23;
              --overview-fg-color: #e5e1e6;

              --sidebar-bg-color: #201f23;
              --sidebar-fg-color: #e5e1e6;
              --sidebar-backdrop-color: @window_bg_color;
              --sidebar-border-color: @window_bg_color;

              --warning-bg-color: #603b4f;
              --warning-fg-color: #ffd8e9;
              --warning-color: #ebb9d0;

              --success-color: #c7c4dc;
              --success-bg-color: #464559;
              --success-fg-color: #e4dff9;

              --shade-color: rgba(0, 0, 0, 0.36);
          }
        '';
    };

  m.default =
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
            css = lib.mkOption {
              type = with lib.types; nullOr lines;
              default = "";
              description = "Raw css content";
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
