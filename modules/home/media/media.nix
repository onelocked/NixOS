{
  flake.modules.nixos.default =
    { pkgs, ... }:
    {
      hj.packages = with pkgs; [
        jellyfin-desktop
        moonlight-qt
        ayugram-desktop
      ];
    };
}
