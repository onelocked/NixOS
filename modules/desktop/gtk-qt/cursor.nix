{
  exo.mods.desktop =
    {
      lib,
      pkgs,
      config,
      self',
      hostName,
      ...
    }:
    let
      cfg = config.forte.cursor;
    in
    {
      config = {
        forte.cursor = lib.mkIf (hostName != "gaming-pc") {
          name = "aemeath-cursor";
          size = 24;
          package = self'.legacyPackages.aemeath-cursor;
        };
        hj.packages = [ cfg.package ];
        hj.environment.sessionVariables = {
          XCURSOR_SIZE = cfg.size;
          XCURSOR_THEME = cfg.name;
        };
        forte.allowUnfree = [ "apple_cursor" ];
      };

      options.forte.cursor = {
        name = lib.mkOption {
          description = "Cursor theme";
          type = lib.types.str;
          default = "macOS-White";
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
          default = pkgs.apple-cursor;
        };
      };
    };
  tack.aemeath-cursor = {
    url = "https://s3.onelock.org/download/cursors/aemeath-cursor.tar.gz";
    fetch = true;
  };
  omniSystem =
    { pkgs, inputs, ... }:
    {
      legacyPackages = {
        aemeath-cursor = pkgs.stdenvNoCC.mkDerivation (finalAttrs: {
          name = "aemeath-cursor";
          version = "1.0";
          src = inputs.aemeath-cursor;

          dontConfigure = true;
          dontBuild = true;

          installPhase = ''
            mkdir -p $out/share/icons/${finalAttrs.name}
            cp -r . $out/share/icons/${finalAttrs.name}
          '';
        });
      };
    };
}
