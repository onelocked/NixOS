{
  exo.mods.desktop =
    { pkgs, lib, ... }:
    {
      config = {
        services.ddccontrol.enable = true;
        hj.packages = with pkgs; [
          silicon
          wl-clipboard
          ddcutil
          app2unit
        ];
        hj.environment.sessionVariables = {
          APP2UNIT_SLICES = "a=app-graphical.slice b=background-graphical.slice s=session-graphical.slice";
          APP2UNIT_TYPE = "service";
          NIXOS_OZONE_WL = "1";
        };
      };
      options.desktop = {
        media.enable = lib.mkEnableOption null // {
          default = true;
        };
        remote-access.enable = lib.mkEnableOption null // {
          default = true;
        };
      };
    };
}
