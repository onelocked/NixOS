{ self, ... }:
{
  flake.nixosModules.core = {
    # Timezone and locale
    time.timeZone = "${self.variables.timezone}";
    i18n.defaultLocale = "${self.variables.locale}";
    i18n.extraLocaleSettings = {
      LC_ADDRESS = "${self.variables.locale}";
      LC_IDENTIFICATION = "${self.variables.locale}";
      LC_MEASUREMENT = "${self.variables.locale}";
      LC_MONETARY = "${self.variables.locale}";
      LC_NAME = "${self.variables.locale}";
      LC_NUMERIC = "${self.variables.locale}";
      LC_PAPER = "${self.variables.locale}";
      LC_TELEPHONE = "${self.variables.locale}";
      LC_TIME = "${self.variables.locale}";
    };
    system.stateVersion = "25.11";
  };
}
