{ inputs, ... }:
{
  ff.nix-gaming-edge = {
    url = "github:powerofthe69/nix-gaming-edge";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  exo.mods.desktop =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.forte.gaming;
    in
    {
      options.forte.gaming = {
        enable = lib.mkEnableOption "Gaming";
      };

      config = lib.mkIf cfg.enable {
        nix.settings = {
          substituters = [ "https://nix-cache.tokidoki.dev/tokidoki" ];
          trusted-public-keys = [ "tokidoki:MD4VWt3kK8Fmz3jkiGoNRJIW31/QAm7l1Dcgz2Xa4hk=" ];
        };

        nixpkgs.overlays = with inputs.nix-gaming-edge.overlays; [ proton-cachyos ];

        programs.steam = {
          enable = true;
          remotePlay.openFirewall = true;
          localNetworkGameTransfers.openFirewall = true;
          extraCompatPackages = with pkgs; [
            proton-ge-bin
            dwproton-bin
            proton-cachyos-x86_64-v3
          ];
        };
        programs.gamemode.enable = true;
        programs.gamescope = {
          enable = true;
          args = [
            "-W 3440"
            "-H 1440"
            "-f"
          ];
        };

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
        hardware.steam-hardware.enable = true;

        forte.persist.home.directories = [
          ".steam"
          ".local/share/Steam"
          ".local/share/vulkan"
          ".cache/nvidia"
          ".cache/winetricks"
          ".cache/umu-protonfixes"
        ];
      };
    };
}
