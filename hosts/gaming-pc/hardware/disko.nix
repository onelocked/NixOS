{ inputs, ... }:
{
  ff = {
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  exo.hardware.gaming-pc = {
    imports = [ inputs.disko.nixosModules.disko ];

    fileSystems."/nix".neededForBoot = true;
    fileSystems."/persist".neededForBoot = true;

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
    disko.devices.disk.storage = {
      device = "/dev/nvme1n1";
      type = "disk";
      content.type = "gpt";

      content.partitions.storage = {
        name = "storage";
        size = "100%";

        content = {
          type = "btrfs";
          extraArgs = [ "-f" ];

          subvolumes = {
            "@steam" = {
              mountpoint = "/steam";
              mountOptions = [
                "noatime"
                "nodatacow"
              ];
            };

            "@games" = {
              mountpoint = "/games";
              mountOptions = [
                "noatime"
                "nodatacow"
              ];
            };
          };
        };
      };
    };
  };
}
