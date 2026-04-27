{
  inputs,
  self,
  ...
}:
{
  ff = {
    niri = {
      url = "github:niri-wm/niri/b82d52705e1424cf47b26dd7b096832901c31f56";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.rust-overlay.follows = "rust-overlay";
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  perSystem =
    { inputs', ... }:
    {
      packages.niri = inputs'.niri.packages.default.overrideAttrs { doCheck = false; };
    };
  m.niri =
    {
      pkgs,
      config,
      lib,
      self',
      ...
    }:
    let
      niriWrapped = inputs.wrappers.wrappers.niri.wrap {
        inherit pkgs;
        package = self'.packages.niri;
        v2-settings = true;
        inherit (config.custom.programs.niri) settings;
      };
      inherit (self.variables) username;
    in
    lib.mkMerge [
      {
        programs.niri = {
          enable = true;
          package = niriWrapped;
          useNautilus = false;
        };
      }
      (lib.mkIf (config.programs.niri.enable or false) {
        xdg.portal = {
          config = {
            niri = {
              default = lib.mkForce [ "gnome" ];
              "org.freedesktop.impl.portal.FileChooser" = lib.mkForce [ "termfilechooser" ];
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
              binPath = "${lib.getExe config.programs.niri.package}"; # NOTE: /run/current-system/sw/bin/niri is more preferred to avoid version mismatch
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
      })
    ];
  m.default =
    { lib, ... }:
    {
      options.custom = {
        programs.niri = {
          settings = lib.mkOption {
            default = { };
            type = lib.types.submodule {
              freeformType = lib.types.attrs;
              options = {
                binds = lib.mkOption {
                  default = { };
                  type = lib.types.attrs;
                };
                layout = lib.mkOption {
                  default = { };
                  type = lib.types.attrs;
                };
                spawn-at-startup = lib.mkOption {
                  default = [ ];
                  type = lib.types.listOf (lib.types.either lib.types.str (lib.types.listOf lib.types.str));
                };
                window-rules = lib.mkOption {
                  default = [ ];
                  type = lib.types.listOf lib.types.attrs;
                };
                layer-rules = lib.mkOption {
                  default = [ ];
                  type = lib.types.listOf lib.types.attrs;
                };
                workspaces = lib.mkOption {
                  default = { };
                  type = lib.types.attrsOf (lib.types.nullOr lib.types.anything);
                };
                outputs = lib.mkOption {
                  default = { };
                  type = lib.types.attrs;
                };
                # change to lines to allow merging
                extraConfig = lib.mkOption {
                  default = "";
                  type = lib.types.lines;
                };
              };
            };
          };
        };
      };
    };
}
