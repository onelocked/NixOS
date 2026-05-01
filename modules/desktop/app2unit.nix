{
  m.desktop =
    { pkgs, ... }:
    {
      environment = {
        systemPackages = [ pkgs.app2unit ];
        sessionVariables = {
          APP2UNIT_SLICES = "a=app-graphical.slice b=background-graphical.slice s=session-graphical.slice";
          APP2UNIT_TYPE = "service";
          NIXOS_OZONE_WL = "1";
        };
      };
    };
}
