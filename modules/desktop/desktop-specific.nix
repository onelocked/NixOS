{
  tack.inputs.fetch.app2unit = "gh:Vladimir-csp/app2unit";
  exo.mods.desktop =
    {
      pkgs,
      lib,
      inputs,
      ...
    }:
    {
      config = {
        services.ddccontrol.enable = true;
        services.gnome.gnome-keyring.enable = true;
        services.displayManager.enable = lib.mkForce false;

        services = {
          scx = {
            enable = true;
            package = pkgs.scx.rustscheds;
            scheduler = "scx_cake"; # https://wiki.cachyos.org/configuration/sched-ext/#scx_cake
          };
        };

        services.journald = {
          storage = lib.mkForce "volatile";
          extraConfig = lib.mkForce "";
        };

        security = {
          polkit.enable = true;
        };

        programs.seahorse.enable = false;

        forte.persist = {
          home.directories = [
            ".local/share/keyrings"
          ];
        };
        hj.packages = with pkgs; [
          silicon
          wl-clipboard
          ddcutil
          app2unit
        ];

        services.gvfs.enable = false;

        nixpkgs.overlays = [
          (_: prev: {
            app2unit = prev.app2unit.overrideAttrs (oldAttrs: {
              src = inputs.app2unit;
            });
          })
        ];
        hj.environment.sessionVariables = {
          APP2UNIT_SLICES = "a=app-graphical.slice b=background-graphical.slice s=session-graphical.slice";
          APP2UNIT_TYPE = "service";
          NIXOS_OZONE_WL = "1";
        };
      };
    };
}
