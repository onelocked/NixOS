{
  flake.modules.nixos.hardware-mini-pc = {
    boot = {
      tmp.cleanOnBoot = true;
      supportedFilesystems = [
        "ntfs"
        "exfat"
        "ext4"
        "fat32"
        "btrfs"
      ];
    };

    fileSystems."/" = {
      device = "/dev/disk/by-uuid/b2c1e345-6468-4e25-87c9-9caddf42b0c4";
      fsType = "ext4";
    };

    fileSystems."/boot" = {
      device = "/dev/disk/by-uuid/7D2B-A8AB";
      fsType = "vfat";
      options = [
        "fmask=0022"
        "dmask=0022"
      ];
    };
    swapDevices = [
      { device = "/dev/disk/by-uuid/0c7c2788-d1a2-4720-908a-f6636da3b1ab"; }
    ];
  };
}
