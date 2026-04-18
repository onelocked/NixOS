{ inputs, ... }:
{
  m.yazi =
    {
      pkgs,
      config,
      ...
    }:
    {
      nixpkgs.overlays = [
        (_: prev: {
          yazi = inputs.wrappers.wrappers.yazi.wrap {
            pkgs = prev;
            extraPackages = with prev; [
              ouch
            ];
            inherit (config.custom.programs.yazi) plugins;
            settings = with config.custom.programs; {
              keymap = yazi.keymap;
              yazi = yazi.settings;
              theme = yazi.theme;
            };
            constructFiles.initLua = {
              relPath = "yazi-config/init.lua";
              content = config.custom.programs.yazi.initLua;
            };
            constructFiles.oneshillFlavor = {
              relPath = "yazi-config/flavors/oneshill.yazi/flavor.toml";
              content = config.custom.programs.yazi.flavorContent;
            };
          };
        })
      ];

      hj.packages = [
        pkgs.yazi
      ];
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

  m.default =
    { pkgs, lib, ... }:
    let
      inherit (pkgs.formats.toml { }) type;
      default = { };
      mkMapOption = description: lib.mkOption { inherit type description default; };
    in
    {
      options.custom.programs.yazi = {
        plugins = lib.mkOption {
          type = lib.types.attrsOf (lib.types.nullOr lib.types.path);
          default = { };
          description = "Yazi plugins";
        };

        flavors = lib.mkOption {
          type = lib.types.attrsOf (lib.types.nullOr lib.types.path);
          default = { };
          description = "Yazi flavors";
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
          type = type;
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
            freeformType = type;
            options = {
              mgr = mkMapOption ''
                Manager settings
                See <https://yazi-rs.github.io/docs/configuration/yazi#mgr>
              '';

              preview = mkMapOption ''
                Preview settings
                See <https://yazi-rs.github.io/docs/configuration/yazi#preview>
              '';

              opener = mkMapOption ''
                Opener settings
                See <https://yazi-rs.github.io/docs/configuration/yazi#opener>
              '';

              open = mkMapOption ''
                Open settings
                See <https://yazi-rs.github.io/docs/configuration/yazi#open>
              '';

              plugin = mkMapOption ''
                Plugin settings
                See <https://yazi-rs.github.io/docs/configuration/yazi#plugin>
              '';

              input = mkMapOption ''
                Input settings
                See <https://yazi-rs.github.io/docs/configuration/yazi#input>
              '';

              confirm = mkMapOption ''
                Confirm settings
                See <https://yazi-rs.github.io/docs/configuration/yazi#confirm>
              '';

              pick = mkMapOption ''
                Pick settings
                See <https://yazi-rs.github.io/docs/configuration/yazi#pick>
              '';

              which = mkMapOption ''
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
            freeformType = type;
            options = {
              mgr = mkMapOption ''
                Keymap mgr settings
                See <https://yazi-rs.github.io/docs/configuration/keymap#mgr>
              '';

              tasks = mkMapOption ''
                Keymap tasks settings
                See <https://yazi-rs.github.io/docs/configuration/keymap#tasks>
              '';

              spot = mkMapOption ''
                Keymap spot settings
                See <https://yazi-rs.github.io/docs/configuration/keymap#spot>
              '';

              pick = mkMapOption ''
                Keymap pick settings
                See <https://yazi-rs.github.io/docs/configuration/keymap#pick>
              '';

              input = mkMapOption ''
                Keymap input settings
                See <https://yazi-rs.github.io/docs/configuration/keymap#input>
              '';

              confirm = mkMapOption ''
                 Keymap confirm settings
                See < https://yazi-rs.github.io/docs/configuration/keymap#confirm>
              '';

              cmp = mkMapOption ''
                 Keymap cmp settings
                See < https://yazi-rs.github.io/docs/configuration/keymap#cmp>
              '';

              help = mkMapOption ''
                 Keymap help settings
                See < https://yazi-rs.github.io/docs/configuration/keymap#help>
              '';
            };
          };
        };
      };
    };
}
