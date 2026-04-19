{ inputs, ... }:
{
  m.starship =
    { pkgs, lib, ... }:
    let
      tomlFormat = pkgs.formats.toml { };
      starship = inputs.wrappers.lib.wrapPackage {
        inherit pkgs;
        package = pkgs.starship;
        env.STARSHIP_CONFIG = tomlFormat.generate "starship.toml" {
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
          palettes.mocha = {
            color_fg0 = "#cfd3e7"; # text
            color_bg1 = "#2a2a3a"; # slightly lifted surface
            color_bg3 = "#454545"; # overlay1
            color_blue = "#7d75c0"; # blue
            color_aqua = "#c5c0ff"; # teal
            color_green = "#b8db8c"; # green
            color_dark_green = "#8fd4b5"; # sky (brighter, for success ➜)
            color_teal = "#7cb8d4"; # teal
            color_teal1 = "#a8c8f0"; # sapphire (lighter teal for branch text)
            color_orange = "#f2b8a0"; # peach
            color_purple = "#c8b0e8"; # pink
            color_red = "#ff7a6b"; # mauve (your warm red-orange)
            color_red1 = "#f4a8b8"; # red (softer, for error messages)
            color_yellow = "#f6d88a"; # yellow
            color_pink = "#e8c4d8"; # rosewater (soft, for error symbol)
          };
        };
      };
    in
    {
      hj.packages = [ starship ];
      programs = {
        fish = {
          promptInit = # fish
            ''
                if test "$TERM" != "dumb"
                  ${lib.getExe starship} init fish | source
                  "enable_transience"
                end

              # Starship transient prompt
                function starship_transient_prompt_func
                    printf " \e[38;2;232;196;216m\e[0m "
                end
            '';
        };
      };
    };
}
