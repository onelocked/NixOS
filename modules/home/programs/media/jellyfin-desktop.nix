{
  flake.modules.homeManager.jellyfin-desktop =
    { pkgs, ... }:
    {
      home.packages = [
        pkgs.jellyfin-desktop
      ];
    };
}
