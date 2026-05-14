{
  lib,
  inputs,
  withSystem,
  config,
  ...
}:
{
  config.forte.lib = {
    mkSystem =
      {
        modules,
        system ? "x86_64-linux",
      }:
      withSystem system (
        { self', inputs', ... }:
        inputs.nixpkgs.lib.nixosSystem {
          specialArgs =
            let
              constants = {
                username = "onelock";
                homedir = "/home/onelock";
                hostname = "NixOS";
                locale = "en_GB.UTF-8";
                timezone = "Europe/London";
                stateVersion = "25.11";
              };
            in
            {
              inherit self' inputs' constants;
              inherit (inputs) wrappers;
            };
          modules = modules ++ [ config.m.default ];
        }
      );

    resize =
      width: height: app:
      "niri msg action set-window-width ${toString width};niri msg action set-window-height ${toString height};niri msg action center-window;${app}";

  };
  options.forte.lib = lib.mkOption {
    type = lib.types.attrsOf lib.types.unspecified;
    default = { };
  };
}
