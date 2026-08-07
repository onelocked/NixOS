{
  tack.inputs.fetch.app2unit = "gh:Vladimir-csp/app2unit";
  exo.mods.desktop =
    { pkgs, inputs, ... }:
    {
      config = {
        services.ddccontrol.enable = true;
        hj.packages = with pkgs; [
          silicon
          wl-clipboard
          ddcutil
          app2unit
        ];
        nixpkgs.overlays = [
          (_: prev: {
            app2unit = prev.app2unit.overrideAttrs (oldAttrs: {
              src = inputs.app2unit;
            });
          })
        ];
        hj.environment.sessionVariables = {
          APP2UNIT_SLICES = "a=app-graphical.slice b=background-graphical.slice s=session-graphical.slice";
          APP2UNIT_TYPE = "service";
          NIXOS_OZONE_WL = "1";
        };
      };
    };
}
