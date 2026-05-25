{
  envoy = {
    fuzzy-search = {
      github = "onelocked/fuzzy-search.yazi";
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
          extra-metadata = pkgs.yaziPlugins.mkYaziPlugin {
            inherit (envoy.extra-metadata) pname version src;
          };

          confirm-dialog = pkgs.yaziPlugins.mkYaziPlugin {
            pname = "confirm-dialog";
            version = "1.0";
            src = pkgs.writeTextFile {
              name = "confirm-dialog-src";
              destination = "/main.lua";
              text = # lua
                ''
                  local get_hovered = ya.sync(function()
                      local h = cx.active.current.hovered
                      if not h then return nil end
                      return {
                          url     = tostring(h.url),
                          is_dir  = h.cha.is_dir,
                          exists  = h.cha.len ~= nil,
                      }
                  end)

                  local function entry()
                      if not os.getenv("YAZI_CHOOSER_SAVE") then
                          return ya.emit("open", { hovered = true })
                      end

                      local h = get_hovered()
                      if not h then return end

                      if h.is_dir then
                          return ya.emit("enter", {})
                      end

                      if h.exists then
                          local yes = ya.confirm({
                              pos   = { "center", w = 62, h = 10 },
                              title = "Overwrite file?",
                              body  = ui.Text(
                                  h.url .. "\n\nThis file already exists and will be overwritten."
                              ):wrap(ui.Wrap.YES),
                          })
                          if not yes then return end
                      end

                      ya.emit("open", { hovered = true })
                  end

                  return { entry = entry }
                '';
            };
          };
        };
        settings.plugin =
          let
            piper = "piper -- CLICOLOR_FORCE=1 ${lib.getExe pkgs.glow} -w=$w -s=dracula -- $1";
          in
          {
            spotters = [
              {
                url = "*";
                run = "extra-metadata";
              }
            ];
            append_previewers = [
              {
                url = "*";
                run = ''piper -- ${lib.getExe pkgs.hexyl} --border=none --terminal-width=$w "$1"'';
              }
            ];
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
                group = "git";
                url = "*";
                run = "git";
              }
              {
                group = "git";
                url = "*/";
                run = "git";
              }
            ];
          };

        keymap = {
          mgr.prepend_keymap = [
            {
              on = [ "<Enter>" ];
              run = "plugin confirm-dialog";
              desc = "Safe open in chooser mode";
            }
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
