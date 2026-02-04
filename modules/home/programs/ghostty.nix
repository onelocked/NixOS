{
  inputs,
  ...
}:

{
  flake.modules = {
    homeManager = {
      ghostty =
        { pkgs, ... }:
        let
          ghostty-nix = inputs.ghostty.packages.${pkgs.stdenv.hostPlatform.system}.default;
        in
        {
          nix.settings = {
            extra-substituters = [ "https://ghostty.cachix.org" ];
            extra-trusted-public-keys = [ "ghostty.cachix.org-1:QB389yTa6gTyneehvqG58y0WnHjQOqgnA+wBnpWWxns=" ];
          };
          programs.ghostty = {
            enable = true;
            package = ghostty-nix;
            settings = {

              font-family = "Liga SFMono";
              font-style = "Bold";
              font-style-bold = "Heavy";
              font-style-italic = "Bold Italic";
              font-style-bold-italic = "Heavy Italic";
              font-size = "18";

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

              window-vsync = "true"; # https://ghostty.org/docs/config/reference#window-vsync
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
            };
          };
        };
    };
    nixos = {
      home-manager =
        { pkgs, lib, ... }:
        let
          ghostty-nix = inputs.ghostty.packages.${pkgs.stdenv.hostPlatform.system}.default;
        in
        {
          systemd.user.services."app-com.mitchellh.ghostty" = {
            description = "Ghostty Terminal server";
            wantedBy = [ "graphical-session.target" ];
            after = [
              "graphical-session.target"
              "dbus.socket"
            ];
            requires = [ "graphical-session.target" ];
            serviceConfig = {
              Type = "dbus";
              ExecStart = "${lib.getExe ghostty-nix} --initial-window=false";
            };
          };
        };
    };
  };
}
