{
  exo.mods.gaming =
    { constants, ... }:
    {
      forte.gaming = {
        enable = true;
        ntsync.enable = true;
        platformOptimizations.enable = true;
        gamemode.enable = true;
      };

      hardware.steam-hardware.enable = true;

      programs.steam = {
        enable = false; # install via flatpak, for better permission control using flatseal
        remotePlay.openFirewall = false;
        localNetworkGameTransfers.openFirewall = false;
      };

      # Realtime scheduling permissions for games
      # Required because Steam runs in bubblewrap sandbox where capabilities don't work
      security.pam.loginLimits = [
        {
          domain = "@gamemode";
          item = "nice";
          type = "-";
          value = "-20";
        }
        {
          domain = constants.username;
          item = "rtprio";
          type = "-";
          value = "98";
        }
        {
          domain = constants.username;
          item = "nice";
          type = "-";
          value = "-20";
        }
        {
          domain = constants.username;
          item = "memlock";
          type = "-";
          value = "unlimited";
        }
      ];
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
              DXVK_ASYNC = "1";
              # Allow GPU render queueing
              DXGI_MAX_FRAME_LATENCY = "1";
              D3D9_MAX_FRAME_LATENCY = "1";
              MESA_SHADER_CACHE_MAX_SIZE = "10G";
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
                        ".cache/mesa_shader_cache"
                        ".local/share/dxvk-cache"
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
          (lib.mkIf cfg.gamemode.enable {
            programs.gamemode = {
              enable = true;
              settings = {
                cpu = {
                  governor = "performance";
                  energy_perf_preference = "performance";
                };
                custom = {
                  start = "${config.forte.quickshell.package}/bin/tuishell ipc call gamemode set 1";
                  end = "${config.forte.quickshell.package}/bin/tuishell ipc call gamemode set 0";
                };
              };
            };
          })
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
          })
          (lib.mkIf cfg.platformOptimizations.enable {
            boot.kernelParams = [
              "mitigations=off"

              "usbcore.autosuspend=-1" # don't sleep usb devices

              "pcie_aspm=off" # disables PCIe Active State Power Management (ASPM) across all PCIe links on the system
              "nowatchdog" # Disables the software watchdog, freeing up a tiny bit of CPU time
              "nmi_watchdog=0" # Disables the NMI watchdog
              "split_lock_detect=off" # Prevents the kernel from throttling games that use split locks

              "transparent_hugepage=madvise"
              "thp_anon=madvise"

              "hpet=disable" # Kill the High Precision Event Timer
              "tsc=reliable" # Trust the CPU's Time Stamp Counter completely
              "clocksource=tsc" # Force TSC as the system clock source
            ];
            boot.kernel.sysctl = {
              "kernel.sched_cfs_bandwidth_slice_us" = 3000;
              "net.ipv4.tcp_fin_timeout" = 5;
              "kernel.split_lock_mitigate" = 0;
              "vm.max_map_count" = 2147483642;

              # Prevent background writeback micro-stutters
              "vm.dirty_ratio" = 10;
              "vm.dirty_background_ratio" = 5;

              "vm.compaction_proactiveness" = 0;
              "vm.vfs_cache_pressure" = 20;
              "vm.watermark_boost_factor" = 0;
              "vm.watermark_scale_factor" = 125;

              "vm.page-cluster" = 0;
              "vm.stat_interval" = 10;
            };
          })
        ];
      options.forte.gaming = {
        enable = lib.mkEnableOption "Gaming";
        ntsync.enable = lib.mkEnableOption "NTSync support";
        gamemode.enable = lib.mkEnableOption "Gamemode with config";
        platformOptimizations.enable = lib.mkEnableOption "Platform optimizations";
      };
    };
}
