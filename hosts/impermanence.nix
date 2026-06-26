{ inputs, ... }:
{
  ff.preservation.url = "github:nix-community/preservation";
  exo.core =
    {
      config,
      constants,
      lib,
      ...
    }:
    let
      cfg = config.forte.persist;
      assertNoHomeDirs =
        paths:
        assert (
          lib.assertMsg (
            !lib.any (p: lib.hasPrefix "/home/" (if lib.isAttrs p then p.file else p)) paths
          ) "/home used in a root persist!"
        );
        paths;
    in
    {
      imports = [ inputs.preservation.nixosModules.default ];
      options.forte = {
        persist = {
          root = {
            directories = lib.mkOption {
              type = lib.types.listOf lib.types.anything;
              default = [ ];
              apply = assertNoHomeDirs;
              description = "Directories to persist in root filesystem";
            };
            files = lib.mkOption {
              type = lib.types.listOf lib.types.anything;
              default = [ ];
              apply = assertNoHomeDirs;
              description = "Files to persist in root filesystem";
            };
          };
          home = {
            directories = lib.mkOption {
              type = lib.types.listOf lib.types.anything;
              default = [ ];
              description = "Directories to persist in home directory";
            };
            files = lib.mkOption {
              type = lib.types.listOf lib.types.anything;
              default = [ ];
              description = "Files to persist in home directory";
            };
          };
        };
      };

      # setup persistence
      config = {
        boot.tmp = {
          useTmpfs = true;
          tmpfsSize = "75%";
        };
        fileSystems."/nix".neededForBoot = true;
        fileSystems."/persist".neededForBoot = true;

        preservation = {
          enable = true;
          preserveAt = {
            "/persist" = {
              commonMountOptions = [ "x-gvfs-hide" ];
              files = [
                {
                  file = "/etc/machine-id";
                  inInitrd = true;
                }
              ]
              ++ cfg.root.files;
              directories = lib.unique (
                [
                  "/var/lib/nixos" # for persisting user uids and gids
                  "/var/log" # logs
                  "/var/lib/systemd"
                ]
                ++ cfg.root.directories
              );

              users.${constants.username} = {
                files = lib.unique cfg.home.files;
                directories = lib.unique (
                  [
                    "Development"
                    "Documents"
                    "NixOS"
                    "Pictures"
                    "Videos"
                    "Downloads"
                  ]
                  ++ cfg.home.directories
                );
              };
            };
          };
        };
        systemd.suppressedSystemUnits = [ "systemd-machine-id-commit.service" ];
        security.sudo-rs.extraConfig = ''Defaults lecture="never" ''; # shut up sudo
        # set permissions
        systemd.tmpfiles.settings.preservation = {
          "${config.hj.directory}/.ssh".d = lib.mkForce {
            user = constants.username;
            group = "users";
            mode = "0700";
          };
        };
      };
    };
}
