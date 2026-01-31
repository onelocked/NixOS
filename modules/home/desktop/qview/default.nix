{
  flake.modules.homeManager.media =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        qview
      ];
      xdg.configFile."qView/qView.conf".source = ./qView.conf;
    };
}
