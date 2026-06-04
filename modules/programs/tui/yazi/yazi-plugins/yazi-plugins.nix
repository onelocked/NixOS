{
  m.yazi =
    {
      pkgs,
      lib,
      envoy,
      scheme,
      ...
    }:
    {
      forte.yazi = {
        plugins =
          let
            mkPlugin = drv: pkgs.yaziPlugins.mkYaziPlugin { inherit (drv) pname version src; };
          in
          {
            inherit (pkgs.yaziPlugins)
              full-border
              ouch
              lazygit
              git
              piper
              chmod
              smart-filter
              wl-clipboard
              ;
          }
          // lib.genAttrs [ "fuzzy-search" "yaziline" "no-header-prompt" "confirm-dialog" "extra-metadata" ] (
            name: mkPlugin envoy.${name}
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
      forte.yazi.initLua =
        with scheme.withHashtag; # lua
        ''
          require("no-header-prompt"):setup()
          require("full-border"):setup {
          	type = ui.Border.PLAIN,
          }
          require("git"):setup {
              -- Order of status signs showing in the linemode
            order = 1500,
          }
          require("yaziline"):setup({
            color = "${base0D}",               -- blue (active/primary)
            secondary_color = "${base02}",     -- selection background
            default_files_color = "${base04}", -- dark foreground (inactive)
            selected_files_color = "${base05}",-- default foreground
            yanked_files_color = "${base0B}",  -- green
            cut_files_color = "${base08}",     -- red

            separator_style = "liney", -- "angly" | "curvy" | "liney" | "empty"

            select_symbol = "",
            yank_symbol = "󰆐",

            filename_max_length = 24, -- truncate when filename > 24
            filename_truncate_length = 6, -- leave 6 chars on both sides
            filename_truncate_separator = "..."
          })
        '';
    };
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
    yaziline = {
      github = "llanosrocas/yaziline.yazi";
      locked = true;
    };
    no-header-prompt = {
      github = "onelocked/no-header-prompt.yazi";
      locked = true;
    };
  };
}
