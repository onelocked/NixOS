{
  lib,
  config,
  inputs,
  withSystem,
  ...
}:
let
  cfg = config.exo;
in
{
  config = {
    flake.nixosConfigurations =
      cfg.configurations
      |> lib.mapAttrs (
        name: hostConfig:
        withSystem hostConfig.system (
          { self', inputs', ... }:
          inputs.nixpkgs.lib.nixosSystem {
            specialArgs = {
              inherit self' inputs';
              hardware = hostConfig.hardware;
              hostName = name;
            };
            modules = hostConfig.modules ++ [
              config.exo.skeleton
              config.exo.core
              config.exo.hardware.${hostConfig.hardware}
              config.exo.pilot.${hostConfig.user}
              hostConfig.extraConfig
              { networking.hostName = lib.mkDefault name; }
            ];
          }
        )
      );
  };

  options.exo = {
    configurations = lib.mkOption {
      description = "NixOS Configuration";
      default = { };
      type = lib.types.attrsOf (
        lib.types.submodule (
          { name, ... }:
          {
            options = {
              system = lib.mkOption {
                type = lib.types.str;
                default = "x86_64-linux";
                description = "The architecture of the system.";
              };

              user = lib.mkOption {
                type = lib.types.str;
                default = throw "Configuration failed: You must define a `user` for the host '${name}'.";
                description = "The primary user (pilot) for this system.";
              };

              hardware = lib.mkOption {
                type = lib.types.str;
                default = throw "Configuration failed: You must define a `hardware` profile for the host '${name}'.";
                description = "The hardware profile for this system.";
              };

              modules = lib.mkOption {
                type = lib.types.listOf lib.types.deferredModule;
                default = [ ];
                description = "List of modules to include.";
              };

              extraConfig = lib.mkOption {
                type = lib.types.deferredModule;
                default = { };
                description = "configurations specific to this host.";
              };
            };
          }
        )
      );
    };
  };
}
