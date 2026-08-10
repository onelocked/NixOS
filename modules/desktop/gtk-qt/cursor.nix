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
          name = "Bibata-Modern-Classic";
          size = 28;
          package = self'.legacyPackages.cursors.hypr-bibata-classic;
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
          default = "Bibata-Modern-Ice";
        };

        size = lib.mkOption {
          description = "Cursor size";
          type = lib.types.int;
          default = 28;
          apply = toString;
        };

        package = lib.mkOption {
          description = "Cursor theme package";
          type = lib.types.nullOr lib.types.package;
          default = self'.legacyPackages.cursors.hypr-bibata-ice;
        };
      };
    };
  tack.inputs = {
    fixed = {
      saturnian-night = "https://s3.onelock.org/download/cursors/saturnian-night.tar.gz";
      saturnian-light = "https://s3.onelock.org/download/cursors/saturnian-light.tar.gz";
    };
    fetch = {
      hypr-bibata-ice = "https://github.com/LOSEARDES77/Bibata-Cursor-hyprcursor/releases/download/1.0/hypr_Bibata-Modern-Ice.tar.gz";
      hypr-bibata-classic = "https://github.com/LOSEARDES77/Bibata-Cursor-hyprcursor/releases/download/1.0/hypr_Bibata-Modern-Classic.tar.gz";
    };
  };
  perSystem =
    { pkgs, inputs, ... }:
    {
      legacyPackages = {
        cursors = {

          hypr-bibata-ice = pkgs.stdenvNoCC.mkDerivation (finalAttrs: {
            name = "Bibata-Modern-Ice";
            version = "1.0";
            src = inputs.hypr-bibata-ice;

            dontConfigure = true;
            dontBuild = true;

            installPhase = ''
              mkdir -p $out/share/icons/${finalAttrs.name}
              cp -r . $out/share/icons/${finalAttrs.name}
            '';
          });

          hypr-bibata-classic = pkgs.stdenvNoCC.mkDerivation (finalAttrs: {
            name = "Bibata-Modern-Classic";
            version = "1.0";
            src = inputs.hypr-bibata-classic;

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
