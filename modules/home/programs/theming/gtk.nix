{
  flake.modules.homeManager.gtk =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      inherit (lib) mkForce;
    in
    {
      gtk = {
        enable = true;
        gtk4.extraCss = mkForce config.gtk.gtk3.extraCss;
        gtk3.extraCss = mkForce ''
          @import url("noctalia.css");
        '';
        gtk2.extraConfig = ''
          gtk-xft-antialias=1
          gtk-xft-hinting=1
          gtk-xft-hintstyle="hintslight"
          gtk-xft-rgba="rgb"
        '';
        gtk3.extraConfig = mkForce {
          gtk-xft-antialias = 1;
          gtk-xft-hinting = 1;
          gtk-xft-hintstyle = "hintslight";
          gtk-xft-rgba = "rgb";
          gtk-decoration-layout = "menu:";
        };
        gtk4.extraConfig = mkForce {
          gtk-decoration-layout = "menu:";
        };
        theme = {
          package = pkgs.adw-gtk3;
          name = "adw-gtk3-dark";
        };
        iconTheme = {
          package = pkgs.papirus-icon-theme;
          name = "Papirus-Dark";
        };
        font = {
          name = "SFPro Text";
          size = 14;
        };
      };
    };
}
