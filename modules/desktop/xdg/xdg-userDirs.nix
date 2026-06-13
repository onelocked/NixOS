{
  exo.mods.desktop = {
    forte.xdg.userDirs = {
      enable = true;
      createDirectories = true;
    };
  };
  exo.skeleton =
    {
      config,
      lib,
      pkgs,
      ...
    }:

    let
      inherit (lib) literalExpression mkOption types;
      cfg = config.forte.xdg.userDirs;
    in
    {
      options.forte.xdg.userDirs = {
        enable = mkOption {
          type = types.bool;
          default = false;
          description = ''
            Whether to manage {file}`$XDG_CONFIG_HOME/user-dirs.dirs`.

            The generated file is read-only.
          '';
        };

        package = lib.mkPackageOption pkgs "xdg-user-dirs" { nullable = true; };

        # Well-known directory list from
        # https://gitlab.freedesktop.org/xdg/xdg-user-dirs/blob/master/man/user-dirs.dirs.xml

        documents = mkOption {
          type = with types; nullOr (coercedTo path toString str);
          default = "${config.hj.directory}/Documents";
          defaultText = literalExpression ''"''${config.hj.directory}/Documents"'';
          description = "The Documents directory.";
        };

        download = mkOption {
          type = with types; nullOr (coercedTo path toString str);
          default = "${config.hj.directory}/Downloads";
          defaultText = literalExpression ''"''${config.hj.directory}/Downloads"'';
          description = "The Downloads directory.";
        };

        pictures = mkOption {
          type = with types; nullOr (coercedTo path toString str);
          default = "${config.hj.directory}/Pictures";
          defaultText = literalExpression ''"''${config.hj.directory}/Pictures"'';
          description = "The Pictures directory.";
        };

        videos = mkOption {
          type = with types; nullOr (coercedTo path toString str);
          default = "${config.hj.directory}/Videos";
          defaultText = literalExpression ''"''${config.hj.directory}/Videos"'';
          description = "The Videos directory.";
        };

        development = mkOption {
          type = with types; nullOr (coercedTo path toString str);
          default = "${config.hj.directory}/Development";
          defaultText = literalExpression ''"''${config.hj.directory}/Development"'';
          description = "Development directory";
        };

        createDirectories = lib.mkEnableOption "automatic creation of the XDG user directories";
      };

      config =
        let
          directories =
            {
              DOCUMENTS = cfg.documents;
              DOWNLOAD = cfg.download;
              PICTURES = cfg.pictures;
              VIDEOS = cfg.videos;
              DEVELOPMENT = cfg.development;
            }
            |> lib.filterAttrs (_n: v: !isNull v);

          bindings = directories |> lib.mapAttrs' (k: lib.nameValuePair "XDG_${k}_DIR");
        in
        lib.mkIf cfg.enable {
          hj = {
            xdg.config.files."user-dirs.dirs".text =
              let
                # For some reason, these need to be wrapped with quotes to be valid.
                wrapped = lib.mapAttrs (_: value: ''"${value}"'') bindings;
              in
              lib.generators.toKeyValue { } wrapped;

            xdg.config.files."user-dirs.conf".text = "enabled=False";

            packages = lib.mkIf (cfg.package != null) [ cfg.package ];

            systemd.services.create-xdg-user-dirs = {
              description = "Create XDG user directories";
              wantedBy = [ "default.target" ];
              serviceConfig = {
                Type = "oneshot";
                RemainAfterExit = true;
              };
              script =
                directories
                |> lib.attrValues
                |> lib.concatMapStringsSep "\n" (dir: ''
                  [[ -L "${dir}" ]] || mkdir -p "${dir}"
                '');
            };
          };
        };
    };
}
