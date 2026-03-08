{
  flake.modules.homeManager.media-default =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        #Programs
        vesktop
        moonlight-qt
        telegram-desktop
        parsec-bin
      ];
    };
}
