{
  flake.modules.homeManager.ghostty = {
    programs.ghostty = {
      enable = true;
      systemd = {
        enable = true;
      };
      installBatSyntax = true;
      settings = {

        font-family = "Liga SFMono";
        font-style = "Bold";
        font-style-bold = "Heavy";
        font-style-italic = "Bold Italic";
        font-style-bold-italic = "Heavy Italic";
        font-size = "15";

        theme = "noctalia";
        cursor-style = "bar";
        cursor-style-blink = "true";
        link-url = "true";
        class = "com.mitchellh.ghostty";

        resize-overlay = "never";
        confirm-close-surface = "false";
        gtk-single-instance = "true";
        window-padding-x = "18";
        window-padding-y = "10";
        quit-after-last-window-closed = "false";

        window-vsync = "true"; # NOTE: https://ghostty.org/docs/config/reference#window-vsync
        window-decoration = "server";
        window-save-state = "never";
        right-click-action = "copy";
        clipboard-read = "allow";
        clipboard-write = "allow";
        clipboard-trim-trailing-spaces = "true";
        clipboard-paste-protection = "true";
        shell-integration = "nushell";
        desktop-notifications = "true";
        auto-update = "off";
        custom-shader-animation = false;
      };
    };
  };
}
