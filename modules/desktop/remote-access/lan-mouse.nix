{
  tack.inputs.lan-mouse = "gh:feschber/lan-mouse";
  exo.mods.remote-access = {
    forte.lan-mouse = {
      openFirewall = true;
      settings = {
        authorized_fingerprints = {
          "50:96:77:ad:06:2c:ef:52:71:8a:1d:92:1c:56:e7:a4:95:3b:b0:6c:9f:cd:b2:66:b4:01:a2:d6:24:d0:cd:a0" =
            "Windows";
        };
      };
    };
  };
  exo.skeleton =
    {
      self',
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.forte.lan-mouse;
      tomlFormat = pkgs.formats.toml { };
    in
    {
      config = lib.mkIf cfg.enable {
        hj.systemd.services.lan-mouse = {
          description = "Lan Mouse Daemon";
          wantedBy = [ "graphical-session.target" ];
          partOf = [ "graphical-session.target" ];
          after = [
            "graphical-session.target"
            "network-online.target"
          ];
          wants = [ "network-online.target" ];
          environment = {
            RUST_BACKTRACE = "0";
            RUST_LOG = "error";
          };
          serviceConfig = {
            Type = "simple";
            ExecStart = "${lib.getExe cfg.package} daemon";
            Restart = "on-failure";
            RestartSec = 1;
            TimeoutStopSec = 10;
          };
        };
        hj.xdg.config.files."lan-mouse/config.toml" = lib.mkIf (cfg.settings != { }) {
          generator = tomlFormat.generate "lan-mouse-config";
          value = cfg.settings;
        };
        networking.firewall.allowedUDPPorts = lib.mkIf cfg.openFirewall [ 4242 ];
        forte.persist.home.directories = [ ".config/lan-mouse" ];
      };
      options.forte.lan-mouse = {
        enable = lib.mkEnableOption "lan-mouse" // {
          default = true;
        };
        package = lib.mkOption {
          type = lib.types.package;
          default = self'.packages.lan-mouse;
          description = "The package to use for lan-mouse";
        };
        settings = lib.mkOption {
          inherit (tomlFormat) type;
          default = { };
          description = ''
            Optional configuration written to {file}`$XDG_CONFIG_HOME/lan-mouse/config.toml`.

            See <https://github.com/feschber/lan-mouse/> for
            available options and documentation.
          '';
        };
        openFirewall = lib.mkEnableOption null // {
          description = ''
            Whether to open the firewall for lan-mouse.
          '';
        };
      };
    };
  perSystem =
    { packages', pkgs, ... }:
    {
      packages.lan-mouse = packages'.lan-mouse.overrideAttrs (oldAttrs: {
        doCheck = false;
        patches = (oldAttrs.patches or [ ]) ++ [
          (pkgs.writeText "disable-side-buttons" # rust
            ''
              diff --git a/src/capture.rs b/src/capture.rs
              index 8f739bd..f37803c 100644
              --- a/src/capture.rs
              +++ b/src/capture.rs
              @@ -322,6 +322,14 @@ impl CaptureTask {
                       let (handle, event) = event;
                       log::trace!("({handle}): {event:?}");

              +        if let CaptureEvent::Input(Event::Pointer(input_event::PointerEvent::Button {
              +            button: input_event::BTN_BACK | input_event::BTN_FORWARD,
              +            ..
              +        })) = event
              +        {
              +            return Ok(());
              +        }
              +
                       if capture.keys_pressed(&self.release_bind.borrow()) {
                           log::info!("releasing capture: release-bind pressed");
                           return self.release_capture(capture).await;
              diff --git a/src/emulation.rs b/src/emulation.rs
              index 923bf99..63eb224 100644
              --- a/src/emulation.rs
              +++ b/src/emulation.rs
              @@ -278,6 +278,14 @@ impl EmulationProxy {
                   }

                   fn consume(&self, event: Event, addr: SocketAddr) {
              +        if let Event::Pointer(input_event::PointerEvent::Button {
              +            button: input_event::BTN_BACK | input_event::BTN_FORWARD,
              +            ..
              +        }) = event
              +        {
              +            return;
              +        }
              +
                       // ignore events if emulation is currently disabled
                       if self.emulation_active.get() {
                           self.request_tx
            ''
          )
        ];
      });
    };
}
