{
  exo.mods.desktop =
    { pkgs, ... }:
    {
      services.ddccontrol.enable = true;
      hj.packages = with pkgs; [
        silicon
        wl-clipboard
        ddcutil
      ];
    };
}
