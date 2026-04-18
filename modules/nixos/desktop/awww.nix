{
  m.default =
    { lib, pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.awww ];
      systemd.user.services.awww = {
        description = "awww wallpaper daemon";
        wantedBy = [ "graphical-session.target" ];
        partOf = [ "graphical-session.target" ];
        after = [ "graphical-session.target" ];
        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.awww}/bin/awww-daemon";
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
