{
  flake.modules.nixos.desktop =
    { pkgs, ... }:
    {

      services.displayManager.autoLogin.enable = true;
      services.displayManager.autoLogin.user = "onelock";
      services.displayManager = {
        sddm = {
          enable = true;
          wayland.enable = true;
          enableHidpi = true;
          package = pkgs.kdePackages.sddm;
          theme = "${pkgs.sddm-onelock}/share/sddm/themes/sddm-onelock-theme";
          settings.Theme.CursorTheme = "Bibata-Modern-Ice";
          extraPackages = with pkgs; [
            kdePackages.qtmultimedia
            kdePackages.qtsvg
            kdePackages.qtvirtualkeyboard
          ];
        };
      };
    };
}
