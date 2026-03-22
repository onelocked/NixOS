{
  flake.modules.homeManager.yazi =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    {
      programs.yazi = {
        plugins =
          let
            pluginNames = [
              "starship"
              "full-border"
              "no-status"
              "ouch"
              "lazygit"
              "git"
              "piper"
            ];
          in
          builtins.listToAttrs (
            map (name: {
              inherit name;
              value = pkgs.yaziPlugins.${name};
            }) pluginNames
          );
        settings = {
          plugin = {
            prepend_previewers = [
              {
                url = "*.md";
                run = "piper -- CLICOLOR_FORCE=1 ${lib.getExe pkgs.glow} -w=$w -s=dracula -- $1";
              }
            ];
            prepend_preloaders = [
              {
                url = "*.md";
                run = "piper -- CLICOLOR_FORCE=1 ${lib.getExe pkgs.glow} -w=$w -s=dracula -- $1";
              }
            ];
            prepend_fetchers = [
              {
                id = "git";
                url = "*";
                run = "git";
              }
              {
                id = "git";
                url = "*/";
                run = "git";
              }
            ];
          };
        };
        initLua = # lua
          ''
            require("starship"):setup({
                hide_flags = false, -- Default: false
                flags_after_prompt = true, -- Default: true
                config_file = "${config.xdg.configHome}/starship.toml", -- Default: nil
            })
            require("no-status"):setup()
            require("full-border"):setup {
            	type = ui.Border.ROUNDED,
            }
            require("git"):setup {
                -- Order of status signs showing in the linemode
              order = 1500,
            }
          '';
      };
    };
}
