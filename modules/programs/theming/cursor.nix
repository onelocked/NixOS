{
  m.cursor =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    let
      gtkCursor = config.custom.gtk.cursor;

      default_cursor_path = "${gtkCursor.package}/share/icons/${gtkCursor.name}/cursors/left_ptr";

      default_index_theme_package = pkgs.writeTextFile {
        name = "index.theme";
        destination = "/share/icons/default/index.theme";
        # Set name in icons theme, for compatibility with AwesomeWM etc. See:
        # https://github.com/nix-community/home-manager/issues/2081
        # https://wiki.archlinux.org/title/Cursor_themes#XDG_specification
        text = ''
          [Icon Theme]
          Name=Default
          Comment=Default Cursor Theme
          Inherits=${gtkCursor.name}
        '';
      };
    in
    {
      environment = {
        sessionVariables = {
          XCURSOR_SIZE = gtkCursor.size;
          XCURSOR_THEME = gtkCursor.name;
        };

        systemPackages = [
          gtkCursor.package
        ];
      };

      hj = {
        xdg.data.files = {
          "icons/${gtkCursor.name}".source = "${gtkCursor.package}/share/icons/${gtkCursor.name}";
          "icons/default/index.theme".source =
            "${default_index_theme_package}/share/icons/default/index.theme";
        };

        packages = [
          default_index_theme_package
        ];

        files = {
          ".icons/default/index.theme".source =
            "${default_index_theme_package}/share/icons/default/index.theme";
          ".icons/${gtkCursor.name}".source = "${gtkCursor.package}/share/icons/${gtkCursor.name}";

          ".Xresources".text = ''
            Xcursor.theme = ${gtkCursor.name};
            Xcursor.size = ${toString gtkCursor.size};
          '';

          ".xprofile".text = ''
            if [ -e "$HOME/.profile" ]; then
              . "$HOME/.profile"
            fi

            # If there are any running services from a previous session.
            # Need to run this in xprofile because the NixOS xsession
            # script starts up graphical-session.target.
            systemctl --user stop graphical-session.target graphical-session-pre.target

            ${lib.getExe pkgs.xsetroot} -xcf ${default_cursor_path} ${toString gtkCursor.size}

            export HM_XPROFILE_SOURCED=1
          '';
        };
      };
    };

  m.default =
    { self', lib, ... }:
    {
      options.custom = {
        gtk = {
          cursor = {
            package = lib.mkOption {
              type = lib.types.package;
              default = self'.legacyPackages.aemeath-cursor;
              description = "Package providing the cursor theme.";
            };

            name = lib.mkOption {
              type = lib.types.str;
              default = "aemeath-cursor";
              description = "The cursor name within the package.";
            };

            size = lib.mkOption {
              type = lib.types.int;
              default = 24;
              description = "The cursor size.";
            };
          };
        };
      };
    };
  envoy.aemeath-cursor = {
    tarball = "https://s3.onelock.org/download/cursors/aemeath-cursor.tar.gz";
    locked = true;
  };
  perSystem =
    { pkgs, envoy, ... }:
    {
      legacyPackages.aemeath-cursor = pkgs.stdenvNoCC.mkDerivation (finalAttrs: {
        name = envoy.aemeath-cursor.pname;
        version = "1.0";
        inherit (envoy.aemeath-cursor) src;

        dontConfigure = true;
        dontBuild = true;

        installPhase = ''
          mkdir -p $out/share/icons/${finalAttrs.name}
          cp -r . $out/share/icons/${finalAttrs.name}
        '';
      });
    };
}
