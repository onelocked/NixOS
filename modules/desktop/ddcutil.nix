{
  exo.mods.desktop =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [ ddcutil ];
      services.ddccontrol.enable = true;
    };
}
