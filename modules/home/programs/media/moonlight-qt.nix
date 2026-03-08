{
  flake.modules.nixos.moonlight-qt =
    { pkgs, ... }:
    {
      home.packages = [
        pkgs.moonlight-qt
      ];
    };
}
