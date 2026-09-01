{
  exo.mods.gaming =
    { pkgs, constants, ... }:
    {
      forte.gaming = {
        enable = true;
        ntsync.enable = true;
        platformOptimizations.enable = true;
        gamemode.enable = true;
      };

      hardware.steam-hardware.enable = true;

      programs.steam = {
        enable = true;
        extraPackages = with pkgs; [
          mangohud
          gamemode
          pulseaudio
          systemd
        ];
        package = pkgs.steam.override {
          extraLibraries = pkgs: [
            pkgs.mangohud
            pkgs.gamemode.lib
          ];
          extraEnv = {
            DBUS_FATAL_WARNINGS = "0";
            GAMEMODERUNEXEC = "mangohud";

            PROTON_ENABLE_WAYLAND = 1;
            DXVK_ASYNC = "1";
            # Allow GPU render queueing
            DXGI_MAX_FRAME_LATENCY = "1";
            D3D9_MAX_FRAME_LATENCY = "1";
            MESA_SHADER_CACHE_MAX_SIZE = "10G";
          };
          extraPreBwrapCmds = # bash
            ''
              # Prevent buildFHSEnv from automatically bind-mounting all root host directories (like /home, /root, /var, etc.)
              ignored+=(/*)
            '';
          extraBwrapArgs = [
            "--ro-bind-try /sys /sys"
            "--ro-bind-try /run/udev /run/udev"
            "--ro-bind-try /run/opengl-driver /run/opengl-driver"
            "--ro-bind-try /run/opengl-driver-32 /run/opengl-driver-32"
            "--ro-bind-try /run/current-system /run/current-system"
            "--ro-bind-try /run/dbus /run/dbus"
            "--ro-bind-try /run/nscd /run/nscd"
            "--ro-bind-try /run/systemd /run/systemd"

            "--bind-try /tmp/.X11-unix /tmp/.X11-unix"
            "--bind-try $XDG_RUNTIME_DIR/$WAYLAND_DISPLAY $XDG_RUNTIME_DIR/$WAYLAND_DISPLAY"
            "--bind-try $XDG_RUNTIME_DIR/wayland-0 $XDG_RUNTIME_DIR/wayland-0"
            "--bind-try $XDG_RUNTIME_DIR/pipewire-0 $XDG_RUNTIME_DIR/pipewire-0"
            "--bind-try $XDG_RUNTIME_DIR/pulse $XDG_RUNTIME_DIR/pulse"
            "--bind-try $XDG_RUNTIME_DIR/bus $XDG_RUNTIME_DIR/bus"
            "--ro-bind-try $XDG_RUNTIME_DIR/speech-dispatcher $XDG_RUNTIME_DIR/speech-dispatcher"
            "--bind-try $XDG_RUNTIME_DIR/gamemode $XDG_RUNTIME_DIR/gamemode"

            "--tmpfs $HOME"
            "--bind-try $HOME/.steam $HOME/.steam"
            "--bind-try $HOME/.local/share/Steam $HOME/.local/share/Steam"
            "--bind-try $HOME/.local/share/vulkan $HOME/.local/share/vulkan"
            "--bind-try $HOME/.cache/winetricks $HOME/.cache/winetricks"
            "--bind-try $HOME/.cache/umu-protonfixes $HOME/.cache/umu-protonfixes"
            "--bind-try $HOME/.cache/mesa_shader_cache $HOME/.cache/mesa_shader_cache"
            "--bind-try $HOME/.cache/mesa_shader_cache_db $HOME/.cache/mesa_shader_cache_db"
            "--bind-try $HOME/.cache/nvidia $HOME/.cache/nvidia"
            "--bind-try $HOME/.nv $HOME/.nv"
            "--ro-bind-try $HOME/.config/MangoHud $HOME/.config/MangoHud"
            "--ro-bind-try $HOME/.config/fontconfig $HOME/.config/fontconfig"
            "--ro-bind-try $HOME/.icons $HOME/.icons"
            "--ro-bind-try $HOME/.local/share/icons $HOME/.local/share/icons"
            "--ro-bind-try $HOME/.local/share/fonts $HOME/.local/share/fonts"
            "--bind-try $HOME/.local/share/applications $HOME/.local/share/applications"

            "--bind-try /games /games"
            "--bind-try /steam /steam"

            "--unshare-uts"
            "--unshare-ipc"
          ];
        };
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
                  name = "steam-big-picture",
                  match = {
                    title = "Steam Big Picture Mode",
                    class = "^steam$",
                  },
                  fullscreen_state = "3 3",
                })

                hl.window_rule({
                  name = "move-all-games",
                  match = {
                    xdg_tag = "proton-game"
                  },
                  decorate = false,
                  content = "game",
                  workspace = "name:games",
                  fullscreen_state = "3 3",
                })

                -- return to workspace media once the game is closed
                hl.on("window.close", function()
                  local ws = hl.get_active_workspace()
                  if ws ~= nil and ws.name == "games" then
                    local windows = hl.get_workspace_windows(ws.name)
                    if windows ~= nil and #windows <= 1 then
                      hl.dispatch(hl.dsp.focus({ workspace = "media" }))
                    end
                  end
                end)
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
          (lib.mkIf config.programs.steam.enable {
            hj.systemd.services = {
              steam-autostart = {
                enableDefaultPath = false;
                description = "steam autostart";
                after = [ "graphical-session.target" ];
                wantedBy = [ "graphical-session.target" ];
                serviceConfig = {
                  Type = "simple";
                  ExecStart = "${lib.getExe config.programs.steam.package} -gamepadui";
                };
              };
            };
          })
          (lib.mkIf cfg.gamemode.enable {
            programs.gamemode = {
              enable = true;
              settings = {
                general = {
                  softrealtime = "auto";
                  renice = 15;
                };
                cpu = {
                  governor = "performance";
                  energy_perf_preference = "performance";
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
