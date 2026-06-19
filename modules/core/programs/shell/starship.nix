{
  exo.core =
    { scheme, ... }:
    {
      forte.starship = {
        enable = true;
        settings = {
          add_newline = false;
          format = "[ 󰪥 $directory ](color_green)$character";
          palette = "mocha";
          right_format = "$all";
          command_timeout = 1000;
          character = {
            vimcmd_symbol = "[](color_teal)";
            success_symbol = "[➜](color_teal1)";
            error_symbol = "[](color_red)";
          };
          git_branch = {
            format = "[$symbol$branch(:$remote_branch)](color_teal1)";
            symbol = "󰘬 ";
          };
          git_commit = {
            commit_hash_length = 6;
            tag_symbol = " ";
          };
          git_status = {
            ahead = "  ";
            behind = "  ";
            untracked = " 󰯇 ";
            modified = "  ";
            deleted = "  ";
          };
          directory = {
            read_only = " ";
            truncation_length = 6;
            format = "[󰉋 ](color_blue)[$path](color_aqua)";
          };
          golang = {
            format = "[ ](bold cyan)";
          };
          nix_shell = {
            format = "[$symbol$state( ($name))](color_fg0) ";
            impure_msg = "[impure](color_red1)";
            pure_msg = "[pure](color_dark_green)";
            symbol = " ";
          };
          docker_context = {
            symbol = "[󰡨 ](bold sky)";
          };
          palettes.mocha = with scheme.withHashtag; {
            color_fg0 = base05;
            color_bg1 = base01;
            color_bg3 = base03;
            color_blue = base0D;
            color_aqua = base0C;
            color_green = base0B;
            color_dark_green = base14;
            color_teal = base15;
            color_teal1 = base16;
            color_orange = base09;
            color_purple = base0E;
            color_red = base08;
            color_red1 = base12;
            color_yellow = base0A;
            color_pink = base17;
          };
        };
      };
    };
  exo.skeleton =
    {
      pkgs,
      lib,
      config,
      birdee,
      ...
    }:
    let
      cfg = config.forte.starship;
      toml = pkgs.formats.toml { };
    in
    {
      options.forte.starship = {
        enable = lib.mkEnableOption "starship";
        settings = lib.mkOption {
          inherit (toml) type;
          default = { };
          description = "Options to go into otter-launcher's toml config";
        };
        package = lib.mkOption {
          default = birdee.lib.wrapPackage (
            { config, ... }:
            {
              inherit pkgs;
              package = pkgs.starship;
              env.STARSHIP_CONFIG = config.constructFiles.starship.path;
              constructFiles.starship = {
                relPath = "starship.toml";
                builder = ''mkdir -p "$(dirname "$2")" && cp ${toml.generate "starship.toml" cfg.settings} "$2"'';
              };
            }
          );
        };
      };

      config = lib.mkIf cfg.enable {
        hj.packages = [ cfg.package ];
        programs.fish.promptInit = # fish
          ''
            if test "$TERM" != "dumb"
              ${lib.getExe cfg.package} init fish | source
              enable_transience
            end
            # Starship transient prompt
            function starship_transient_prompt_func
              printf " \e[38;2;${
                if config.forte.theme.variant == "dark" then "232;196;216" else "122;24;48"
              }m\e[0m "
            end
          '';
      };
    };
}
