{
  lib,
  config,
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
        hostName: hostConfig:
        withSystem hostConfig.system (
          {
            self',
            inputs',
            inputs,
            packages',
            rootPath,
            ...
          }:
          lib.nixosSystem {
            specialArgs = {
              inherit
                inputs
                self'
                inputs'
                packages'
                rootPath
                hostName
                ;
              inherit (hostConfig) hardware theme;
              constants = {
                username = hostConfig.user;
                homedir = "/home/${hostConfig.user}";
              };
            };
            modules = hostConfig.modules ++ [
              cfg.skeleton
              cfg.core
              cfg.hardware.${hostConfig.hardware}
              hostConfig.extraConfig
              { networking.hostName = lib.mkDefault hostName; }
            ];
          }
        )
      );
    exo.core =
      { config, constants, ... }:
      let
        password = config.sops.secrets."linux-password".path;
      in
      {
        sops.secrets."linux-password".neededForUsers = true; # Required for pre-user-creation
        users = {
          mutableUsers = false;
          users.root.hashedPasswordFile = password;
          users.${constants.username} = {
            hashedPasswordFile = password;
            isNormalUser = true;
            useDefaultShell = true;
            extraGroups = [
              "networkmanager"
              "wheel"
              "kvm"
              "input"
              "disk"
              "libvirtd"
              "video"
              "audio"
            ];
          };
        };
      };
    perSystem =
      { pkgs, ... }:
      {
        formatter = pkgs.nixfmt-rs;
      };
  };

  options = {
    perSystem = lib.mkOption { type = lib.types.deferredModule; };
    flake = lib.mkOption { type = lib.types.lazyAttrsOf lib.types.unspecified; };

    systems = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "x86_64-linux" ];
    };
    exo = {
      core = lib.mkOption { type = lib.types.deferredModule; };
      skeleton = lib.mkOption { type = lib.types.deferredModule; };
      mods = lib.mkOption { type = lib.types.lazyAttrsOf lib.types.deferredModule; };
      hardware = lib.mkOption { type = lib.types.lazyAttrsOf lib.types.deferredModule; };

      configurations = lib.mkOption {
        description = "NixOS Configuration";
        default = { };
        type = lib.types.attrsOf (
          lib.types.submodule (
            { hostName, ... }:
            {
              options = {
                system = lib.mkOption {
                  type = lib.types.str;
                  default = "x86_64-linux";
                  description = "The architecture of the system.";
                };

                user = lib.mkOption {
                  type = lib.types.str;
                  default = throw "Configuration failed: You must define a `user` for the host '${hostName}'.";
                  description = "The primary user for this system.";
                };

                hardware = lib.mkOption {
                  type = lib.types.str;
                  default = throw "Configuration failed: You must define a `hardware` profile for the host '${hostName}'.";
                  description = "The hardware profile for this system.";
                };

                theme = lib.mkOption {
                  type = lib.types.enum [
                    "light"
                    "dark"
                  ];
                  default = "dark";
                  description = "The color theme for this system.";
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
  };
}
