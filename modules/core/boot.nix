{
  tack.inputs.nixos-core = "gh:manic-systems/nixos-core";
  exo.core =
    {
      inputs,
      lib,
      server,
      ...
    }:
    {
      imports = [ inputs.nixos-core.nixosModules.default ];
      config = {
        system.nixos-core.enable = true;
        boot.loader = {
          timeout = 10;
          efi.canTouchEfiVariables = !server;

          systemd-boot = lib.mkIf (!server) {
            enable = true;
            configurationLimit = 10;
          };

          grub = lib.mkIf server {
            enable = true;
            efiSupport = true;
            efiInstallAsRemovable = true;
          };
        };
      };
    };
}
