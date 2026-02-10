{
  flake.modules.homeManager.vicinae =
    { lib, ... }:
    {
      programs.vicinae = {
        enable = true;
        useLayerShell = true;
        systemd = {
          enable = true;
          autoStart = true;
        };
      };
      systemd.user.services.vicinae.Service = {
        Environment = lib.mkForce [
          "QT_SCALE_FACTOR=1.5"
        ];
      };
    };
}
