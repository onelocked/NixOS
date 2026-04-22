{
  m.desktop =
    { pkgs, lib, ... }:
    {
      networking.firewall.allowedUDPPorts = [ 4242 ];
      hj.systemd.services.lan-mouse = {
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
          ExecStart = "${pkgs.lan-mouse}/bin/lan-mouse daemon";
          Restart = "on-failure";
          RestartSec = 1;
          TimeoutStopSec = 10;
          Environment = lib.mkForce [
            "RUST_BACKTRACE=0"
            "RUST_LOG=error"
          ];
        };
      };
    };
}
