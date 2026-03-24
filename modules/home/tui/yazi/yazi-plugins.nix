{ self, inputs, ... }:
{
  flake-file.inputs.fuzzy-search-yazi = {
    url = "github:onelocked/fuzzy-search.yazi";
    inputs = {
      nixpkgs.follows = "nixpkgs";
    };
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
      programs.yazi =
        let
          _ = lib.getExe;
        in
        {
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
          fuzzy-search = {
            enable = true;
            depth = 3;
            keymaps = {
              fd = true;
              rg = true;
              zoxide = true;
            };
          };
          settings = {
            plugin = {
              prepend_previewers = [
                {
                  url = "*.md";
                  run = "piper -- CLICOLOR_FORCE=1 ${_ pkgs.glow} -w=$w -s=dracula -- $1";
                }
                {
                  url = self.variables.homedir + "/NixOS" + "/**/";
                  run = "piper -- ${_ pkgs.eza} -TL=3 --color=always --icons=always --group-directories-first --no-quotes $1";
                }
                {
                  url = config.xdg.userDirs.extraConfig.PROJECTS + "/**/";
                  run = "piper -- ${_ pkgs.eza} -TL=3 --color=always --icons=always --group-directories-first --no-quotes $1";
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
