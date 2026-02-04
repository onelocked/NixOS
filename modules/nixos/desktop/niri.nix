{
  flake.modules.nixos.desktop =
    { pkgs, ... }:
    {
      nix.settings = {
        extra-substituters = [ "https://niri.cachix.org" ];
        extra-trusted-public-keys = [ "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964=" ];
      };
      programs.niri = {
        enable = true;
        useNautilus = false;
      };
      programs.xwayland = {
        enable = true;
      };
      services.displayManager.sessionPackages = [ pkgs.niri ];
      services.displayManager.defaultSession = "niri";
      systemd.user.services.niri-flake-polkit = {
        description = "PolicyKit Authentication by KDE";
        wantedBy = [ "niri.service" ];
        after = [ "graphical-session.target" ];
        partOf = [ "graphical-session.target" ];
        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.kdePackages.polkit-kde-agent-1}/libexec/polkit-kde-authentication-agent-1";
          Restart = "on-failure";
          RestartSec = 1;
          TimeoutStopSec = 10;
        };
      };
    };
}
