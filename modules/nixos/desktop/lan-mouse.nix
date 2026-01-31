{ inputs, ... }:
{
  flake.modules.nixos.lan-mouse =
    {
      pkgs,
      ...
    }:
    let
      lan-mouse-nix = inputs.lan-mouse.packages.${pkgs.stdenv.hostPlatform.system}.default;
    in
    {

      systemd.user.services.lan-mouse = {
        description = "Lan Mouse Daemon";
        wantedBy = [ "graphical-session.target" ];
        partOf = [ "graphical-session.target" ];
        after = [
          "graphical-session.target"
          "network-online.target"
        ];
        wants = [ "network-online.target" ];
        serviceConfig = {
          Type = "simple";
          ExecStart = "${lan-mouse-nix}/bin/lan-mouse daemon";
          Restart = "on-failure";
          RestartSec = 1;
          TimeoutStopSec = 10;
        };
      };
    };
}
