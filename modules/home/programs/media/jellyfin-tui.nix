{
  flake.modules.homeManager = {
    jellyfin-tui = {
      programs.jellyfin-tui = {
        enable = true;
        settings = {
          servers = [
            {
              name = "Jellyfish";
              quick_connect = true;
              url = "https://jellyfin.onelock.org";
            }
          ];
          keymapInherit = true;
          extraConfig = ''
            keymap:
              ctrl-c: Quit
              Ctrl-Right: !Seek 5
              Ctrl-Left: !Seek -5
              left: PreviousPane
              right: NextPane
              =: VolumeUp
          '';
        };
      };
    };
    default =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      let
        cfg = config.programs.jellyfin-tui;
        baseConfig = (pkgs.formats.yaml { }).generate "config.yaml" {
          servers = cfg.settings.servers;
          keymap_inherit = cfg.settings.keymapInherit;
        };
      in
      {
        options.programs.jellyfin-tui = {
          enable = lib.mkEnableOption "jellyfin-tui";
          package = lib.mkOption {
            type = lib.types.package;
            default = pkgs.jellyfin-tui;
            defaultText = lib.literalExpression "pkgs.jellyfin-tui";
            description = "The jellyfin-tui package to use.";
          };
          settings = {
            servers = lib.mkOption {
              type = lib.types.listOf lib.types.attrs;
              default = [ ];
            };
            keymapInherit = lib.mkOption {
              type = lib.types.bool;
              default = true;
            };
            extraConfig = lib.mkOption {
              type = lib.types.lines;
              default = "";
              description = "Raw YAML appended to the config (use for !Tag style values)";
            };
          };
        };
        config = lib.mkIf cfg.enable {
          home.packages = [ cfg.package ];
          xdg.configFile."jellyfin-tui/config.yaml".text = lib.mkAfter ''
            ${builtins.readFile baseConfig}
            ${cfg.settings.extraConfig}
          '';
        };
      };
  };
}
