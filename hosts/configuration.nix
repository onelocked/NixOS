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
    ff = {
      flake-parts = {
        url = "github:hercules-ci/flake-parts";
        inputs.nixpkgs-lib.follows = "nixpkgs";
      };
      birdee = {
        url = "github:BirdeeHub/nix-wrapper-modules";
        inputs.nixpkgs.follows = "nixpkgs";
      };
      systems.url = "github:nix-systems/x86_64-linux";
    };

    systems = import inputs.systems;

    flake.nixosConfigurations =
      cfg.configurations
      |> lib.mapAttrs (
        hostName: hostConfig:
        withSystem hostConfig.system (
          { self', inputs', ... }:
          inputs.nixpkgs.lib.nixosSystem {
            specialArgs = {
              inherit self' inputs' hostName;
              inherit (inputs) birdee;
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
    perSystem =
      { pkgs, ... }:
      {
        formatter = pkgs.nixfmt-rs;
        _module.args = { inherit (inputs) birdee; };
      };
  };

  options.exo = {
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
    mods = lib.mkOption {
      type = lib.types.lazyAttrsOf lib.types.deferredModule;
    };
    core = lib.mkOption {
      type = lib.types.deferredModule;
    };
    skeleton = lib.mkOption {
      type = lib.types.deferredModule;
    };
    hardware = lib.mkOption {
      type = lib.types.lazyAttrsOf lib.types.deferredModule;
    };
  };
}
