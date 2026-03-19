{
  flake.modules.homeManager.telegram-desktop =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        ayugram-desktop
      ];
    };
}
