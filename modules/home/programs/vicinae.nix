{
  flake.modules.homeManager.vicinae =
    { lib, config, ... }:
    {
      programs.vicinae = {
        enable = true;
        useLayerShell = true;
        systemd = {
          enable = true;
          autoStart = true;
        };
      };
      systemd.user.services.vicinae.Service = lib.mkIf config.programs.vicinae.enable {
        Environment = lib.mkForce [
          "QT_SCALE_FACTOR=1.5"
        ];
      };
    };
}
