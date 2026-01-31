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
      ];
    };
}
