{ self, ... }:
{
  m.desktop =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        ddcutil
      ];

      services.udev.extraRules = ''
        KERNEL=="i2c-[0-9]*", GROUP="i2c", MODE="0660"
      '';
      boot.kernelModules = [ "i2c-dev" ];
      users.groups.i2c = { };
      users.users.${self.variables.username}.extraGroups = [ "i2c" ];
    };
}
