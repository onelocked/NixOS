{ inputs, lib, ... }:
{
  tack.inputs.nixos-hardware = "gh:NixOS/nixos-hardware";
  exo.configurations = {
    tethys = {
      system = "aarch64-linux";
      user = "onelock";
      hardware = "pi5";
      server = true;
      theme = "light";
      extraConfig = {
        imports = [ inputs.nixos-hardware.nixosModules.raspberry-pi-5 ];
        boot.supportedFilesystems.zfs = false;
        boot.loader.generic-extlinux-compatible.enable = lib.mkForce true;
        hardware.raspberry-pi.firmware = {
          enable = true;
          uboot.enable = true;
        };
      };
    };
  };
  exo.disko.pi5 = {
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
      device = "/dev/sda";
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
                swapfile.size = "4G";
              };
            };
          };
        };
      };
    };
  };
}
