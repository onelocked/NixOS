{
  exo.mods.desktop =
    {
      lib,
      pkgs,
      config,
      ...
    }:
    let
      cfg = config.forte.cursor;
    in
    {
      config = {
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
}
