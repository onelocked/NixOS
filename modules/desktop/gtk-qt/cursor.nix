{
  exo.mods.desktop =
    {
      lib,
      pkgs,
      config,
      envoy,
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
          name = envoy.aemeath-cursor.pname;
          size = 24;
          package = self'.legacyPackages.aemeath-cursor;
        };
        hj.packages = [ cfg.package ];
        hj.environment.sessionVariables = {
          XCURSOR_SIZE = cfg.size;
          XCURSOR_THEME = cfg.name;
        };
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
  envoy.aemeath-cursor = {
    tarball = "https://s3.onelock.org/download/cursors/aemeath-cursor.tar.gz";
    locked = true;
  };
  perSystem =
    { pkgs, envoy, ... }:
    {
      legacyPackages = {
        aemeath-cursor = pkgs.stdenvNoCC.mkDerivation (finalAttrs: {
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
    };
}
