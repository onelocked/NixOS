{
  exo.skeleton =
    {
      lib,
      config,
      pkgs,
      ...
    }:
    {
      options.forte.xdg.desktopEntries = lib.mkOption {
        description = "Custom Desktop Entries";
        default = { };
        type = lib.types.attrsOf (
          lib.types.submodule {
            options = {
              type = lib.mkOption {
                description = "The type of the desktop entry.";
                default = "Application";
                type = lib.types.enum [
                  "Application"
                  "Link"
                  "Directory"
                ];
              };
              exec = lib.mkOption {
                description = "Program to execute, possibly with arguments.";
                type = lib.types.nullOr lib.types.str;
                default = null;
              };
              icon = lib.mkOption {
                description = "Icon to display in file manager, menus, etc.";
                type = with lib.types; nullOr (either str path);
                default = null;
              };
              comment = lib.mkOption {
                description = "Tooltip for the entry.";
                type = lib.types.nullOr lib.types.str;
                default = null;
              };
              terminal = lib.mkOption {
                description = "Whether the program runs in a terminal window.";
                type = lib.types.nullOr lib.types.bool;
                default = false;
              };
              name = lib.mkOption {
                description = "Specific name of the application.";
                default = "";
                type = lib.types.str;
              };
              genericName = lib.mkOption {
                description = "Generic name of the application.";
                type = lib.types.nullOr lib.types.str;
                default = null;
              };
              mimeType = lib.mkOption {
                description = "The MIME type(s) supported by this application.";
                type = lib.types.nullOr (lib.types.listOf lib.types.str);
                default = null;
              };
              categories = lib.mkOption {
                description = "Categories in which the entry should be shown in a menu.";
                type = lib.types.nullOr (lib.types.listOf lib.types.str);
                default = null;
              };
              startupNotify = lib.mkOption {
                description = "If true, it is KNOWN that the app will send a remove message.";
                type = lib.types.nullOr lib.types.bool;
                default = null;
              };
              noDisplay = lib.mkOption {
                description = "Means this application exists, but don't display it in the menus.";
                type = lib.types.nullOr lib.types.bool;
                default = null;
              };
              prefersNonDefaultGPU = lib.mkOption {
                description = "If true, the application prefers to be run on a more powerful discrete GPU.";
                type = lib.types.nullOr lib.types.bool;
                default = null;
              };
              settings = lib.mkOption {
                type = lib.types.attrsOf lib.types.str;
                description = "Extra key-value pairs to add to the `[Desktop Entry]` section.";
                default = { };
              };
              actions = lib.mkOption {
                type = lib.types.attrsOf (
                  lib.types.submodule (
                    { name, ... }:
                    {
                      options = {
                        name = lib.mkOption {
                          type = lib.types.str;
                          default = name;
                          description = "Name of the action.";
                        };
                        exec = lib.mkOption {
                          type = lib.types.nullOr lib.types.str;
                          default = null;
                          description = "Program to execute.";
                        };
                        icon = lib.mkOption {
                          type = with lib.types; nullOr (either str path);
                          default = null;
                          description = "Icon to display.";
                        };
                      };
                    }
                  )
                );
                default = { };
                description = "The set of actions made available to application launchers.";
              };
            };
          }
        );
      };
      config =
        let
          makeFile =
            name: cfg:
            pkgs.makeDesktopItem {
              inherit name;
              inherit (cfg)
                type
                exec
                icon
                comment
                terminal
                genericName
                startupNotify
                noDisplay
                prefersNonDefaultGPU
                actions
                ;
              desktopName = cfg.name;
              mimeTypes = lib.optionals (cfg.mimeType != null) cfg.mimeType;
              categories = lib.optionals (cfg.categories != null) cfg.categories;
              extraConfig = cfg.settings;
            };
          desktopPkgs =
            builtins.attrNames config.forte.xdg.desktopEntries
            |> map (name: makeFile name config.forte.xdg.desktopEntries.${name} |> lib.hiPrio);
        in
        {
          environment.systemPackages = desktopPkgs;
          hj.packages = desktopPkgs;
        };
    };
}
