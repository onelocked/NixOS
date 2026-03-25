{
  inputs,
  self,
  ...
}:
{
  flake-file.inputs = {
    niri.url = "github:niri-wm/niri/wip/branch";
    wrappers = {
      url = "github:Lassulus/wrappers";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  flake.modules.nixos.niri =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    let
      inherit (config.custom.programs.niri) settings;
      niriWrapped =
        (inputs.wrappers.wrapperModules.niri.apply {
          inherit pkgs;
          inherit settings;
        }).wrapper;
    in
    lib.mkMerge [
      {
        programs.niri = {
          enable = true;
          package = niriWrapped;
          useNautilus = false;
        };
      }
      (lib.mkIf (config.programs.niri.enable or false) (
        let
          niri-command = "${lib.getExe' config.programs.niri.package "niri-session"}";
          inherit (self.variables) username;
        in
        {
          xdg.portal = {
            config = {
              niri = {
                "org.freedesktop.impl.portal.FileChooser" = lib.mkForce [
                  "termfilechooser"
                ];
                default = lib.mkForce [ "gnome" ];
                "org.freedesktop.impl.portal.Secret" = lib.mkForce [ "gnome-keyring" ];
                "org.freedesktop.impl.portal.Chooser" = lib.mkForce [ "none" ];
              };
            };
          };
          services = {
            displayManager.enable = lib.mkForce false;
            greetd = {
              enable = true;
              settings = {
                default_session = {
                  command = niri-command;
                  user = username;
                };
              };
            };
          };
          security.pam.services.greetd = {
            enableGnomeKeyring = true;
          };
        }
      ))
    ];
  flake.modules.nixos.default =
    { lib, pkgs, ... }:
    {
      options.custom = {
        programs.niri = {
          settings = lib.mkOption {
            type = lib.types.submodule {
              freeformType = (pkgs.formats.json { }).type;
              # strings don't merge by default
              options.extraConfig = lib.mkOption {
                type = lib.types.lines;
                default = "";
                description = "Additional configuration lines.";
              };
            };
            description = "Niri settings, see https://github.com/Lassulus/wrappers/blob/main/modules/niri/module.nix for available options";
          };
        };
      };
    };
}
