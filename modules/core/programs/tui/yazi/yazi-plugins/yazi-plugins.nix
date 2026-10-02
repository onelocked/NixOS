{
  tack.inputs =
    {
      fuzzy-search = "gh:onelocked/fuzzy-search.yazi";
      confirm-dialog = "gh:onelocked/confirm-dialog.yazi";
      extra-metadata = "gh:boydaihungst/file-extra-metadata.yazi";
      no-header-prompt = "gh:onelocked/no-header-prompt.yazi";
    }
    |> builtins.mapAttrs (
      _: url: {
        inherit url;
        type = "fetch";
        group = "sxyazi";
      }
    );

  exo.core =
    {
      pkgs,
      lib,
      inputs,
      ...
    }:
    {
      forte.yazi = {
        plugins = {
          inherit (pkgs.yaziPlugins)
            full-border
            ouch
            lazygit
            git
            piper
            chmod
            smart-filter
            wl-clipboard
            toggle-pane
            ;
        }
        // (
          [
            "fuzzy-search"
            "no-header-prompt"
            "confirm-dialog"
            "extra-metadata"
          ]
          |> map (
            name:
            lib.nameValuePair name (
              pkgs.yaziPlugins.mkYaziPlugin {
                pname = name;
                version = "git";
                src = inputs.${name};
              }
            )
          )
          |> lib.listToAttrs
        );
        settings.plugin =
          let
            piper = "piper -- CLICOLOR_FORCE=1 ${lib.getExe pkgs.glow} -w=$w -s=dracula -- $1";
            mk = url: run: { inherit url run; };
            mkFetcher = group: url: run: { inherit group url run; };
          in
          {
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
          mgr.prepend_keymap =
            let
              mkKeymap = on: run: desc: { inherit on run desc; };
            in
            [
              (mkKeymap [ "<Enter>" ] "plugin confirm-dialog" "Safe open in chooser mode")
              (mkKeymap [ "t" "s" ] "plugin toggle-pane min-parent" "Show or hide the parent pane")
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
          require("no-header-prompt"):setup()
          require("full-border"):setup {
          	type = ui.Border.PLAIN,
          }
          require("git"):setup {
              -- Order of status signs showing in the linemode
            order = 1500,
          }
        '';
    };
}
