{ inputs, ... }:
{
  flake-file.inputs.fuzzy-search-yazi = {
    url = "github:onelocked/fuzzy-search.yazi/dev";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  flake.modules.homeManager.yazi =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    {
      imports = [ inputs.fuzzy-search-yazi.homeManagerModules.default ];
      home.packages = [ pkgs.ouch ];
      programs.yazi =
        let
          _ = lib.getExe;
        in
        {
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
              ;
          };
          yaziPlugins = {
            plugins = {
              fuzzy-search = {
                enable = true;
                enableFishIntegration = config.programs.fish.enable or false;
                depth = 3;
                keymaps = {
                  fd = true;
                  rg = true;
                  zoxide = true;
                };
              };
            };
          };
          settings = {
            plugin = {
              prepend_previewers = [
                {
                  url = "*.md";
                  run = "piper -- CLICOLOR_FORCE=1 ${_ pkgs.glow} -w=$w -s=dracula -- $1";
                }
              ];
              prepend_preloaders = [
                {
                  url = "*.md";
                  run = "piper -- CLICOLOR_FORCE=1 ${_ pkgs.glow} -w=$w -s=dracula -- $1";
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
          keymap = {
            mgr.prepend_keymap = [
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
            ];
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
