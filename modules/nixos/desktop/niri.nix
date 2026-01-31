{ inputs, ... }:
{
  flake.modules.nixos.desktop =
    { pkgs, ... }:

    let
      niri-unstable = inputs.niri-flake.packages.${pkgs.stdenv.hostPlatform.system}.niri-unstable;
      xwayland-unstable =
        inputs.niri-flake.packages.${pkgs.stdenv.hostPlatform.system}.xwayland-satellite-unstable;
    in
    {
      nix.settings = {
        extra-substituters = [ "https://niri.cachix.org" ];
        extra-trusted-public-keys = [ "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964=" ];
      };
      programs.dconf.enable = true;
      programs.niri = {
        enable = true;
        package = niri-unstable;
        useNautilus = false;
      };
      programs.xwayland = {
        enable = true;
        package = xwayland-unstable;
      };
      services.displayManager.sessionPackages = [
        inputs.niri-flake.packages.${pkgs.stdenv.hostPlatform.system}.niri-unstable
      ];
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
