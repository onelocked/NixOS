{ self, ... }:
{
  flake.modules.nixos.desktop =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      niri-command = "${lib.getExe' config.programs.niri.package "niri-session"}";
      inherit (self.variables) username;
    in
    {
      environment.systemPackages = [
        pkgs.libsecret
      ];
      services.displayManager.enable = lib.mkForce false;
      services.greetd = {
        enable = true;
        settings = {
          default_session = {
            command = niri-command;
            user = username;
          };
        };
      };
      security.pam.services.greetd = {
        enableGnomeKeyring = true;
      };
    };
}
