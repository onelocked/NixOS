{
  tack = {
    yazi = "gh:sxyazi/yazi";
    yazi-plugins = {
      url = "gh:AminurAlam/yazi-plugins";
      fetch = true;
    };
  };
  exo.core =
    {
      pkgs,
      lib,
      config,
      wrapPackage,
      self',
      ...
    }:
    let
      cfg = config.forte.yazi;

      tomlFormat = pkgs.formats.toml { };

      mkTomlOption =
        description:
        lib.mkOption {
          type = tomlFormat.type;
          default = { };
          inherit description;
        };
    in
    {
      config = lib.mkIf cfg.enable {
        forte.xdg.desktopEntries."yazi".noDisplay = true;
        hj.packages = [ cfg.package ];

        programs.fish.functions.y = # fish
          ''
            set -l tmp (mktemp -t "yazi-cwd.XXXXX")
            command yazi $argv --cwd-file="$tmp"
            if read cwd < "$tmp"; and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
              builtin cd -- "$cwd"
            end
            rm -f -- "$tmp"
          '';
      };

      options.forte.yazi = {
        enable = lib.mkEnableOption "yazi";

        package = lib.mkOption {
          type = lib.types.package;
          default =
            let
              yaziConfigDir = pkgs.linkFarm "yazi-config" (
                (lib.optional (cfg.settings != { }) {
                  name = "yazi-config/yazi.toml";
                  path = tomlFormat.generate "yazi.toml" cfg.settings;
                })
                ++ (lib.optional (cfg.keymap != { }) {
                  name = "yazi-config/keymap.toml";
                  path = tomlFormat.generate "keymap.toml" cfg.keymap;
                })
                ++ (lib.optional (cfg.theme != { }) {
                  name = "yazi-config/theme.toml";
                  path = tomlFormat.generate "theme.toml" cfg.theme;
                })
                ++ (lib.mapAttrsToList (
                  name: path: {
                    name = "yazi-config/plugins/${name}.yazi";
                    inherit path;
                  }
                ) (lib.filterAttrs (_: path: path != null) cfg.plugins))
                ++ (lib.optional (cfg.initLua != "") {
                  name = "yazi-config/init.lua";
                  path = pkgs.writeText "init.lua" cfg.initLua;
                })
                ++ (lib.optional (cfg.flavorContent != "") {
                  name = "yazi-config/flavors/oneshill.yazi/flavor.toml";
                  path = pkgs.writeText "flavor.toml" cfg.flavorContent;
                })
              );
            in
            wrapPackage {
              package = self'.packages.yazi;
              runtimePkgs = with pkgs; [
                ouch
                exiv2
                ffmpeg
                xxhash
              ];
              env = {
                YAZI_CONFIG_HOME = "${yaziConfigDir}/yazi-config";
              };
              paths = [ yaziConfigDir ];
            };
          description = "The Yazi package to use, wrapped with required dependencies.";
        };

        plugins = lib.mkOption {
          type = with lib.types; attrsOf (nullOr path);
          default = { };
          description = "Yazi plugins";
        };

        flavorContent = lib.mkOption {
          type = with lib.types; nullOr lines;
          default = "";
          description = "Raw TOML content for the flavor file";
        };

        initLua = lib.mkOption {
          type = with lib.types; nullOr (either path lines);
          default = "";
          description = ''
            The init.lua for Yazi itself.
          '';
          example = lib.literalExpression "./init.lua";
        };

        theme = lib.mkOption {
          type = tomlFormat.type;
          default = { };
          description = "Theme settings";
        };

        settings = lib.mkOption {
          default = { };
          description = ''
            Content of yazi.toml file.
            See the configuration reference at <https://yazi-rs.github.io/docs/configuration/yazi>
          '';
          type = lib.types.submodule {
            freeformType = tomlFormat.type;
            options = {
              mgr = mkTomlOption ''
                Manager settings
                See <https://yazi-rs.github.io/docs/configuration/yazi#mgr>
              '';
              preview = mkTomlOption ''
                Preview settings
                See <https://yazi-rs.github.io/docs/configuration/yazi#preview>
              '';
              opener = mkTomlOption ''
                Opener settings
                See <https://yazi-rs.github.io/docs/configuration/yazi#opener>
              '';
              open = mkTomlOption ''
                Open settings
                See <https://yazi-rs.github.io/docs/configuration/yazi#open>
              '';
              plugin = mkTomlOption ''
                Plugin settings
                See <https://yazi-rs.github.io/docs/configuration/yazi#plugin>
              '';
              input = mkTomlOption ''
                Input settings
                See <https://yazi-rs.github.io/docs/configuration/yazi#input>
              '';
              confirm = mkTomlOption ''
                Confirm settings
                See <https://yazi-rs.github.io/docs/configuration/yazi#confirm>
              '';
              pick = mkTomlOption ''
                Pick settings
                See <https://yazi-rs.github.io/docs/configuration/yazi#pick>
              '';
              which = mkTomlOption ''
                Which settings
                See <https://yazi-rs.github.io/docs/configuration/yazi#which>
              '';
            };
          };
        };

        keymap = lib.mkOption {
          default = { };
          description = ''
            Content of keymap.toml file.
            See the configuration reference at <https://yazi-rs.github.io/docs/configuration/keymap>
          '';
          type = lib.types.submodule {
            freeformType = tomlFormat.type;
            options = {
              mgr = mkTomlOption ''
                Keymap mgr settings
                See <https://yazi-rs.github.io/docs/configuration/keymap#mgr>
              '';
              tasks = mkTomlOption ''
                Keymap tasks settings
                See <https://yazi-rs.github.io/docs/configuration/keymap#tasks>
              '';
              spot = mkTomlOption ''
                Keymap spot settings
                See <https://yazi-rs.github.io/docs/configuration/keymap#spot>
              '';
              pick = mkTomlOption ''
                Keymap pick settings
                See <https://yazi-rs.github.io/docs/configuration/keymap#pick>
              '';
              input = mkTomlOption ''
                Keymap input settings
                See <https://yazi-rs.github.io/docs/configuration/keymap#input>
              '';
              confirm = mkTomlOption ''
                Keymap confirm settings
                See <https://yazi-rs.github.io/docs/configuration/keymap#confirm>
              '';
              cmp = mkTomlOption ''
                Keymap cmp settings
                See <https://yazi-rs.github.io/docs/configuration/keymap#cmp>
              '';
              help = mkTomlOption ''
                Keymap help settings
                See <https://yazi-rs.github.io/docs/configuration/keymap#help>
              '';
            };
          };
        };
      };
    };
  perSystem =
    { inputs', ... }:
    {
      packages.yazi = inputs'.yazi.packages.default.overrideAttrs {
        doCheck = false;
      };
    };
}
