{
  envoy = {
    fuzzy-search = {
      github = "onelocked/fuzzy-search.yazi";
      locked = true;
    };
    confirm-dialog = {
      github = "onelocked/confirm-dialog.yazi";
      locked = true;
    };
    extra-metadata = {
      github = "boydaihungst/file-extra-metadata.yazi";
      locked = true;
    };
  };
  m.yazi =
    {
      pkgs,
      lib,
      config,
      envoy,
      ...
    }:
    {
      forte.yazi = {
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
          fuzzy-search = pkgs.yaziPlugins.mkYaziPlugin { inherit (envoy.fuzzy-search) pname version src; };
          confirm-dialog = pkgs.yaziPlugins.mkYaziPlugin {
            inherit (envoy.confirm-dialog) pname version src;
          };
          extra-metadata = pkgs.yaziPlugins.mkYaziPlugin {
            inherit (envoy.extra-metadata) pname version src;
          };

        };
        settings.plugin =
          let
            piper = "piper -- CLICOLOR_FORCE=1 ${lib.getExe pkgs.glow} -w=$w -s=dracula -- $1";
            mk = url: run: { inherit url run; };
            mkFetcher = group: url: run: { inherit group url run; };
          in
          {
            spotters = [ (mk "*" "extra-metadata") ];
            prepend_previewers = [ (mk "*.md" piper) ];
            prepend_preloaders = [ (mk "*.md" piper) ];
            prepend_fetchers = [
              (mkFetcher "simple-tag" "*" "simple-tag")
              (mkFetcher "simple-tag" "*/" "simple-tag")
              (mkFetcher "git" "*" "git")
              (mkFetcher "git" "*/" "git")
            ];
            append_previewers = [
              (mk "*" ''piper -- ${lib.getExe pkgs.hexyl} --border=none --terminal-width=$w "$1"'')
            ];
          };

        keymap = {
          mgr.prepend_keymap = with config.forte.lib; [
            (mkKeymap [ "<Enter>" ] "plugin confirm-dialog" "Safe open in chooser mode")
            (mkKeymap [ "z" ] "plugin fuzzy-search -- fd --TL=3" "Fuzzy Find Files")
            (mkKeymap [ "<S-s>" ] "plugin fuzzy-search -- rg --TL=3" "Ripgrep Search")
            (mkKeymap [ "<S-z>" ] "plugin fuzzy-search -- zoxide --TL=3" "Zoxide Search")
            (mkKeymap [ "c" "m" ] "plugin chmod" "chmod on files")
            (mkKeymap [ "C" ] "plugin ouch" "Compress files with ouch")
            (mkKeymap [ "f" ] "plugin smart-filter" "Smart filter")
            (mkKeymap [ "<C-y>" ] "plugin wl-clipboard" "copy to clipboard")
          ];
        };
      };
      forte.yazi.initLua = # lua
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
