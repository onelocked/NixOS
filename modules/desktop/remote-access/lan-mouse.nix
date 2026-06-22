{
  ff = {
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lan-mouse = {
      url = "github:feschber/lan-mouse";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.rust-overlay.follows = "rust-overlay";
    };
  };
  exo.mods.desktop = {
    forte.lan-mouse = {
      openFirewall = true;
      settings = {
        authorized_fingerprints = {
          "50:96:77:ad:06:2c:ef:52:71:8a:1d:92:1c:56:e7:a4:95:3b:b0:6c:9f:cd:b2:66:b4:01:a2:d6:24:d0:cd:a0" =
            "Windows";
        };
      };
    };
    forte.persist.home.directories = [ ".config/lan-mouse" ];
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
      options.forte.lan-mouse = {
        enable = lib.mkEnableOption "lan-mouse";
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
      };
    };
  perSystem =
    { inputs', ... }:
    {
      packages.lan-mouse = inputs'.lan-mouse.packages.default.overrideAttrs { doCheck = false; };
    };
}
