{
  exo.mods.desktop =
    { pkgs, ... }:
    {
      hj.packages = with pkgs; [
        silicon
        wl-clipboard
      ];
    };
}
