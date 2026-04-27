{
  envoy.fuzzy-search.github = "onelocked/fuzzy-search.yazi";
  m.yazi =
    {
      pkgs,
      lib,
      config,
      envoy,
      ...
    }:
    {
      custom.programs.yazi = {
        plugins = {
          inherit (pkgs.yaziPlugins)
            starship
            full-border
            no-status
            ouch
            lazygit
            git
            piper
            chmod
            smart-filter
            wl-clipboard
            ;
          fuzzy-search = pkgs.yaziPlugins.mkYaziPlugin {
            inherit (envoy.fuzzy-search) pname version;
            src = lib.cleanSourceWith {
              inherit (envoy.fuzzy-search) src;
              filter = name: _: baseNameOf name == "main.lua";
            };
          };
        };
        settings.plugin =
          let
            piper = "piper -- CLICOLOR_FORCE=1 ${lib.getExe pkgs.glow} -w=$w -s=dracula -- $1";
          in
          {
            prepend_previewers = [
              {
                url = "*.md";
                run = piper;
              }
            ];
            prepend_preloaders = [
              {
                url = "*.md";
                run = piper;
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
        keymap = {
          mgr.prepend_keymap = [
            {
              on = [ "z" ];
              run = "plugin fuzzy-search -- fd --TL=3";
              desc = "Fuzzy Find Files";
            }
            {
              on = [ "<S-s>" ];
              run = "plugin fuzzy-search -- rg --TL=3";
              desc = "Ripgrep Search";
            }
            {
              on = [ "<S-z>" ];
              run = "plugin fuzzy-search -- zoxide --TL=3";
              desc = "Zoxide Search";
            }
            {
              on = [
                "c"
                "m"
              ];
              run = "plugin chmod";
              desc = "chmod on files";
            }
            {
              on = [
                "C"
              ];
              run = "plugin ouch";
              desc = "Compress files with ouch";
            }
            {
              on = [
                "f"
              ];
              run = "plugin smart-filter";
              desc = "Smart filter";
            }
            {
              on = [
                "<C-y>"
              ];
              run = "plugin wl-clipboard";
              desc = "copy to clipboard";
            }
          ];
        };
      };
      custom.programs.yazi.initLua = # lua
        ''
          require("starship"):setup({
              hide_flags = false, -- Default: false
              flags_after_prompt = true, -- Default: true
              config_file = "${config.hj.xdg.config.directory}/starship.toml", -- Default: nil
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
}
