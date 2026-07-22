{
  exo.mods.gaming = {
    forte.gaming = {
      enable = true;
      ntsync.enable = true;
      platformOptimizations.enable = true;
    };

    programs.steam = {
      enable = false; # install via flatpak, for better permission control using flatseal
      remotePlay.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
    };

    programs.gamemode.enable = true;
  };

  exo.skeleton =
    {
      pkgs,
      lib,
      constants,
      config,
      ...
    }:
    let
      cfg = config.forte.gaming;
    in
    {
      config =
        lib.mkIf cfg.enable
        <| lib.mkMerge [
          {
            hj.packages = [ pkgs.protonup-rs ];
            hj.environment.sessionVariables = {
              PROTON_ENABLE_WAYLAND = 1;
            };

            forte.hyprland.lua.window-rules = # lua
              ''
                hl.window_rule({
                  name = "steam-move-workspace",
                  match = { class = "^steam$" },
                  workspace = "name:media silent",
                })

                hl.window_rule({
                  name = "float-steam-sub-windows",
                  match = {
                    title = "negative:Steam",
                    class = "^steam$",
                  },
                  float = true,
                })

                hl.window_rule({
                  name = "hide-steam-windows",
                  match = {
                      title = "^Steam Settings$",
                    class = "^steam$",
                  },
                  border_color = "rgb(fede22)",
                  border_size = 3,

                  float = true,
                  no_screen_share = true,
                })

                hl.window_rule({
                  name = "move-all-games",
                  match = {
                    xdg_tag = "proton-game"
                  },
                  decorate = false,
                  content = "game",
                  workspace = "name:games",
                  sync_fullscreen  = true,
                  fullscreen_state = "3 3",
                })
              '';

            preservation = {
              preserveAt = {
                "/steam" = {
                  commonMountOptions = [ "x-gvfs-hide" ];
                  users.${constants.username} = {
                    directories = (
                      lib.unique [
                        ".local/share/vulkan"
                        ".cache/winetricks"
                        ".cache/umu-protonfixes"
                      ]
                      ++ lib.optionals config.programs.steam.enable [
                        ".steam"
                        ".local/share/Steam"
                      ]
                      ++ lib.optionals (builtins.elem "nvidia" config.services.xserver.videoDrivers) [
                        ".nv"
                        ".cache/nvidia"
                      ]
                    );
                  };
                };
              };
            };
            systemd.tmpfiles.settings.preservation = {
              "/steam".d = {
                user = constants.username;
                group = "users";
                mode = "0755";
              };
              "/games".d = {
                user = constants.username;
                group = "users";
                mode = "0755";
              };
            };

            forte.allowUnfree = [
              "steam"
              "steam-unwrapped"
            ];
          }
          (lib.mkIf cfg.ntsync.enable {
            # support driver for emulation of NT synchronization, used by Wine/Proton
            boot.kernelModules = [ "ntsync" ];
            services.udev.packages = [
              (pkgs.writeTextFile {
                name = "ntsync-udev-rules";
                text = ''KERNEL=="ntsync", MODE="0660", TAG+="uaccess"'';
                destination = "/etc/udev/rules.d/70-ntsync.rules";
              })
            ];
            hj.environment.sessionVariables = {
              PROTON_NO_FSYNC = 1;
            };
          })
          (lib.mkIf cfg.platformOptimizations.enable {
            boot.kernel.sysctl = {
              # 20-shed.conf
              "kernel.sched_cfs_bandwidth_slice_us" = 3000;
              # 20-net-timeout.conf
              # This is required due to some games being unable to reuse their TCP ports
              # if they're killed and restarted quickly - the default timeout is too large.
              "net.ipv4.tcp_fin_timeout" = 5;
              # 30-splitlock.conf
              # Prevents intentional slowdowns in case games experience split locks
              # This is valid for kernels v6.0+
              "kernel.split_lock_mitigate" = 0;
              # 30-vm.conf
              # USE MAX_INT - MAPCOUNT_ELF_CORE_MARGIN.
              # see comment in include/linux/mm.h in the kernel tree.
              "vm.max_map_count" = 2147483642;
            };
          })
        ];
      options.forte.gaming = {
        enable = lib.mkEnableOption "Gaming";
        ntsync.enable = lib.mkEnableOption "NTSync support";
        platformOptimizations.enable = lib.mkEnableOption "Platform optimizations";
      };
    };
}
