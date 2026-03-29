{
  inputs,
  self,
  ...
}:
{
  flake-file.inputs = {
    niri.url = "github:niri-wm/niri/b82d52705e1424cf47b26dd7b096832901c31f56";
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
      niriWrapped = inputs.wrappers.wrapperModules.niri.apply {
        inherit pkgs;
        package = (
          lib.mkForce (
            pkgs.niri.overrideAttrs (oldAttrs: {
              doCheck = false;
            })
          )
        );
        inherit settings;
      };
    in
    lib.mkMerge [
      {
        programs.niri = {
          enable = true;
          package = niriWrapped.wrapper;
          useNautilus = false;
        };
      }
      (lib.mkIf (config.programs.niri.enable or false) (
        let
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
          programs.uwsm = {
            enable = true;
            waylandCompositors = {
              niri = {
                prettyName = "niri";
                comment = "Niri compositor managed by UWSM";
                binPath = "/run/current-system/sw/bin/niri";
                extraArgs = [ "--session" ];
              };
            };
          };
          services = {
            displayManager.enable = lib.mkForce false;
            greetd = {
              enable = true;
              settings = {
                default_session = {
                  command = "${lib.getExe config.programs.uwsm.package} start niri-uwsm.desktop";
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
