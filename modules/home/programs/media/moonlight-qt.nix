{
  flake.modules.homeManager.moonlight-qt =
    { pkgs, ... }:
    {
      home.packages = [
        pkgs.moonlight-qt
      ];
    };
}
