{
  tack.inputs.helium-browser.url = "gh:amaanq/helium-flake";

  exo.mods.desktop = {
    forte.helium-browser = {
      enable = true;
      setAsDefaultBrowser = true;
    };
  };
  exo.skeleton =
    {
      lib,
      packages',
      config,
      ...
    }:
    let
      cfg = config.forte.helium-browser;
    in
    {
      config = lib.mkIf cfg.enable {
        hj.packages = [ cfg.package ];
        forte.persist.home.directories = [
          ".config/net.imput.helium"
          ".cache/net.imput.helium"
        ];
        forte.hyprland.lua = {
          window-rules = # lua
            ''
              hl.window_rule({
                name             = "helium",
                match            = { class = "helium" },
                workspace        = "name:web",
                fullscreen_state = "0 1",
                opacity          = "1 override 0.95 override",
                scrolling_width  = 0.333,
              })
              hl.window_rule({
                name             = "helium-pip",
                match            = { title = "Picture-in-picture" },
                float      = true,
                pin        = true,
                decorate = false,
                size       = { 711, 400 },
                move       = { 0,1040 },
                no_initial_focus = true,
                opacity          = "1 override",
              })
            '';
          keybinds = # lua
            ''
              hl.bind("SUPER + B", function()
                  local win = hl.get_window("class:helium")
                  if win then
                      hl.dispatch(hl.dsp.focus({ window = win }))
                  else
                      hl.dispatch(hl.dsp.exec_raw("helium"))
                  end
              end)
            '';
        };
        xdg.mime = lib.mkIf cfg.setAsDefaultBrowser {
          defaultApplications =
            [
              "application/x-extension-shtml"
              "application/x-extension-xhtml"
              "application/x-extension-html"
              "application/x-extension-xht"
              "application/x-extension-htm"
              "x-scheme-handler/unknown"
              "x-scheme-handler/https"
              "x-scheme-handler/http"
              "application/xhtml+xml"
              "application/json"
              "application/pdf"
              "text/html"
            ]
            |> map (mime: lib.nameValuePair mime [ "helium.desktop" ])
            |> lib.listToAttrs;
        };
      };
      options.forte.helium-browser = {
        enable = lib.mkEnableOption "helium-browser";
        package = lib.mkOption {
          type = lib.types.package;
          default = packages'.helium-browser;
        };
        setAsDefaultBrowser = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Set Zen Browser as default browser.";
        };
      };
    };
}
