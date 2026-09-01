{
  tack.inputs.nixos-core = "gh:manic-systems/nixos-core";
  exo.core =
    {
      inputs,
      lib,
      server,
      pkgs,
      ...
    }:
    {
      imports = [ inputs.nixos-core.nixosModules.default ];
      system.nixos-core.enable = true;

      boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_xanmod_latest;

      zramSwap = {
        enable = true;
        priority = 100;
        memoryPercent = 40;
        algorithm = "zstd";
      };

      boot.loader = {
        timeout = 10;
        efi.canTouchEfiVariables = !server;

        systemd-boot = lib.mkIf (!server) {
          enable = lib.mkDefault true;
          configurationLimit = 10;
        };

        grub = lib.mkIf server {
          enable = lib.mkDefault true;
          efiSupport = lib.mkDefault true;
          efiInstallAsRemovable = lib.mkDefault true;
        };
      };
    };
}
