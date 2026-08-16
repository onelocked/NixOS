{ config, ... }:
{
  exo.configurations = {
    mini-pc = {
      user = "onelock";
      hardware = "mini-pc";
      theme = "dark";
      modules = with config.exo.mods; [
        neovim
        media
        remote-access
      ];
      extraConfig =
        { config, lib, ... }:
        {
          forte.openssh.enable = lib.mkForce false;
          forte.opkssh.enable = true;
          sops.defaultSopsFile = ../../.secrets/personal.yaml;
          forte.persist = {
            home = {
              directories = [
                ".ssh"
                ".local/share/.gnupg"
              ];
            };
          };
          hj.files.".ssh/config".text = # bash
            ''
              Host Raspberry
                User onelock
                HostName 192.168.1.239

              Host gitea.onelock.org
                Port 2222
                IdentitiesOnly yes
                User git
                HostName gitea.onelock.org
                IdentityFile ~/.ssh/id_ed25519_gitea

              Host github.com
                IdentitiesOnly yes
                User git
                HostName github.com
                IdentityFile ~/.ssh/id_ed25519_github

              Host router
                User root
                HostName 192.168.1.1

              Host gaming-pc
                User onelock
                HostName 10.13.37.216
                IdentityFile ~/.ssh/shorekeeper

              Host shorekeeper
                User onelock
                HostName vps.onelock.org
                LocalForward 2053 127.0.0.1:2053
                IdentityFile ~/.ssh/shorekeeper

              Host *
                IdentitiesOnly yes
            '';
          sops.secrets."wg_peer_private_key" = { };
          sops.secrets."wg_peer_psk" = { };
          networking.wg-quick.interfaces = {
            wg0 = {
              autostart = false;
              address = [ "10.10.50.4/32" ];
              postUp = "ip route add 217.182.74.106/32 via 192.168.1.1";
              preDown = "ip route del 217.182.74.106/32 via 192.168.1.1 || true";
              dns = [ "1.1.1.1" ];
              privateKeyFile = config.sops.secrets."wg_peer_private_key".path;
              peers = [
                {
                  publicKey = "isX1x//XqsPSKINt0P6+TQ7V+eTaUJnB3oQqFSzuXzc=";
                  presharedKeyFile = config.sops.secrets."wg_peer_psk".path;
                  endpoint = "vps.onelock.org:4738";
                  allowedIPs = [
                    "1.0.0.0/8"
                    "2.0.0.0/8"
                    "3.0.0.0/8"
                    "4.0.0.0/6"
                    "8.0.0.0/7"
                    "11.0.0.0/8"
                    "12.0.0.0/6"
                    "16.0.0.0/4"
                    "32.0.0.0/3"
                    "64.0.0.0/2"
                    "128.0.0.0/3"
                    "160.0.0.0/5"
                    "168.0.0.0/6"
                    "172.0.0.0/12"
                    "172.32.0.0/11"
                    "172.64.0.0/10"
                    "172.128.0.0/9"
                    "173.0.0.0/8"
                    "174.0.0.0/7"
                    "176.0.0.0/4"
                    "192.0.0.0/9"
                    "192.128.0.0/11"
                    "192.160.0.0/13"
                    "192.169.0.0/16"
                    "192.170.0.0/15"
                    "192.172.0.0/14"
                    "192.176.0.0/12"
                    "192.192.0.0/10"
                    "193.0.0.0/8"
                    "194.0.0.0/7"
                    "196.0.0.0/6"
                    "200.0.0.0/5"
                    "208.0.0.0/4"
                    "1.1.1.1/32"
                  ];
                  persistentKeepalive = 25;
                }
              ];
            };
          };
        };
    };
  };
  exo.hardware.mini-pc =
    {
      self',
      modulesPath,
      lib,
      config,
      ...
    }:
    {
      imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

      powerManagement = {
        enable = true;
        cpuFreqGovernor = "ondemand";
        cpufreq.min = 800000;
      };

      boot.kernelModules = [
        "amd_pstate"
        "kvm-amd"
      ];
      boot.kernelParams = [ "amd_pstate=active" ]; # use active mode (dynamic scaling)
      hardware.enableRedistributableFirmware = true;
      nixpkgs.config.rocmSupport = true;
      hardware.amdgpu.opencl.enable = true;
      boot.initrd.kernelModules = [ "amdgpu" ];
      boot.initrd.availableKernelModules = [
        "nvme"
        "xhci_pci"
        "usb_storage"
        "usbhid"
        "sd_mod"
      ];
      networking.interfaces.eno1.wakeOnLan.enable = true;
      hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

      hj.packages = [ self'.packages.amdgpu_top ];
    };
  exo.disko.mini-pc = {
    boot.tmp.useTmpfs = true;
    boot.tmp.tmpfsSize = "75%";

    boot.kernel.sysctl = {
      "vm.swappiness" = 1;
    };
    disko.devices.nodev = {
      "/" = {
        fsType = "tmpfs";
        mountOptions = [
          "size=25%"
          "mode=755"
        ];
      };
    };

    disko.devices.disk.nixos = {
      device = "/dev/nvme0n1";
      type = "disk";
      content.type = "gpt";

      content.partitions.esp = {
        name = "ESP";
        size = "1G";
        type = "EF00";

        content = {
          type = "filesystem";
          format = "vfat";
          mountpoint = "/boot";
        };
      };

      content.partitions.root = {
        name = "root";
        size = "100%";

        content = {
          type = "btrfs";
          extraArgs = [ "-f" ];

          subvolumes = {
            "@persist" = {
              mountpoint = "/persist";
              mountOptions = [
                "noatime"
                "compress=zstd"
              ];
            };

            "@nix" = {
              mountpoint = "/nix";
              mountOptions = [
                "noatime"
                "compress=zstd"
              ];
            };

            "@swap" = {
              mountpoint = "/.swapvol";
              mountOptions = [ "noatime" ];
              swap = {
                swapfile.size = "8G";
              };
            };
          };
        };
      };
    };
  };
  perSystem =
    { pkgs, ... }:
    {
      packages.amdgpu_top = pkgs.amdgpu_top.overrideAttrs (old: {
        doCheck = false;
        cargoBuildFlags = (old.cargoBuildFlags or [ ]) ++ [
          "--no-default-features"
          "--features"
          "tui,libamdgpu_top/libdrm_link"
        ];
        nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ pkgs.makeWrapper ];
        postInstall = (old.postInstall or "") + ''
          makeWrapper $out/bin/amdgpu_top $out/bin/gtop \
            --add-flags '--dark'
        '';
      });
    };
}
