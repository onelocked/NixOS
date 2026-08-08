{
  exo.mods.desktop =
    {
      lib,
      config,
      self',
      theme,
      ...
    }:
    let
      cfg = config.forte.cursor;
    in
    {
      config = {
        forte.cursor = lib.mkIf (theme == "dark") {
          name = "saturnian-night";
          size = 32;
          package = self'.legacyPackages.cursors.saturnian-night;
        };
        hj.packages = [ cfg.package ];
        hj.environment.sessionVariables = {
          XCURSOR_SIZE = cfg.size;
          XCURSOR_THEME = cfg.name;
          HYPRCURSOR_THEME = cfg.name;
          HYPRCURSOR_SIZE = cfg.size;
        };
      };

      options.forte.cursor = {
        name = lib.mkOption {
          description = "Cursor theme";
          type = lib.types.str;
          default = "Saturnian-Day";
        };

        size = lib.mkOption {
          description = "Cursor size";
          type = lib.types.int;
          default = 32;
          apply = toString;
        };

        package = lib.mkOption {
          description = "Cursor theme package";
          type = lib.types.nullOr lib.types.package;
          default = self'.legacyPackages.cursors.saturnian-light;
        };
      };
    };
  tack.inputs.fixed = {
    saturnian-night = "https://s3.onelock.org/download/cursors/saturnian-night.tar.gz";
    saturnian-light = "https://s3.onelock.org/download/cursors/saturnian-light.tar.gz";
  };
  perSystem =
    { pkgs, inputs, ... }:
    {
      legacyPackages = {
        cursors = {
          saturnian-night = pkgs.stdenvNoCC.mkDerivation (finalAttrs: {
            name = "Saturnian-Night";
            version = "1.0";
            src = inputs.saturnian-night;

            dontConfigure = true;
            dontBuild = true;

            installPhase = ''
              mkdir -p $out/share/icons/${finalAttrs.name}
              cp -r . $out/share/icons/${finalAttrs.name}
            '';
          });

          saturnian-light = pkgs.stdenvNoCC.mkDerivation (finalAttrs: {
            name = "Saturnian-Day";
            version = "1.0";
            src = inputs.saturnian-light;

            dontConfigure = true;
            dontBuild = true;

            installPhase = ''
              mkdir -p $out/share/icons/${finalAttrs.name}
              cp -r . $out/share/icons/${finalAttrs.name}
            '';
          });
        };
      };
    };
}
