{ inputs, ... }:
{
  flake.modules.homeManager.media =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        #Programs
        vesktop
        moonlight-qt
        telegram-desktop
        parsec-bin
        (inputs.wrappers.lib.wrapPackage {
          inherit pkgs;
          package = pkgs.jellyfin-desktop;
          flags = {
            "--platform" = "xcb";
          };
        })
      ];
    };
}
