{
  exo.mods.gaming =
    {
      pkgs,
      lib,
      constants,
      ...
    }:
    {
      nix.settings = {
        substituters = [ "https://nix-cache.tokidoki.dev/tokidoki" ];
        trusted-public-keys = [ "tokidoki:MD4VWt3kK8Fmz3jkiGoNRJIW31/QAm7l1Dcgz2Xa4hk=" ];
      };

      programs.steam = {
        enable = false; # install via flatpak, for better permission control using flatseal
        remotePlay.openFirewall = true;
        localNetworkGameTransfers.openFirewall = true;
      };
      hj.packages = with pkgs; [ protonup-rs ];
      hj.environment.sessionVariables = {
        PROTON_NO_FSYNC = 1;
        PROTON_ENABLE_WAYLAND = 1;
      };
      programs.gamemode.enable = true;
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
            content = "game";
            workspace = "name:games",
          })
        '';
      # preserve steam
      preservation = {
        preserveAt = {
          "/steam" = {
            commonMountOptions = [ "x-gvfs-hide" ];
            users.${constants.username} = {
              directories = lib.unique [
                ".steam"
                ".nv"
                ".local/share/Steam"
                ".local/share/vulkan"
                ".cache/nvidia"
                ".cache/winetricks"
                ".cache/umu-protonfixes"
              ];
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
    };
}
