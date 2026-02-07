{ self, ... }:
{
  flake.modules.nixos.desktop =
    {
      config,
      lib,
      ...
    }:
    let
      niri-command = "${lib.getExe' config.programs.niri.package "niri-session"}";
    in
    {
      services.displayManager.enable = false;
      services.greetd = {
        enable = true;
        settings = {
          default_session = {
            command = niri-command;
            user = self.variables.username;
          };
        };
      };
    };
}
