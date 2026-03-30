{
  flake.modules.nixos.default =
    { pkgs, ... }:
    {
      boot = {
        initrd.systemd.enable = true;
        plymouth = {
          enable = true;
          theme = "rings";
          themePackages = with pkgs; [
            (adi1090x-plymouth-themes.override {
              selected_themes = [ "rings" ];
            })
          ];
        };
        consoleLogLevel = 3;
        kernelParams = [
          "quiet"
          "udev.log_level=3"
          "systemd.show_status=auto"
        ];
      };
    };
}
