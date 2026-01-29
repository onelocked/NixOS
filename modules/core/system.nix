{
  flake.modules.nixos.core =
    { config, pkgs, ... }:
    {
      nix = {
        settings = {
          auto-optimise-store = true;
          substituters = [
            "https://cache.nixos.org/"
            "https://nix-community.cachix.org/"
            "https://cachix.cachix.org"
          ];
          trusted-public-keys = [
            "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
            "cachix.cachix.org-1:eWNHQldwUO7G2VkjpnjDbWwy4KQ/HNxht7H4SSoMckM="
          ];
          experimental-features = [
            "nix-command"
            "flakes"
          ];
          use-xdg-base-directories = false;
          warn-dirty = false;
          keep-outputs = true;
          keep-derivations = true;
        };
        optimise.automatic = true;
        package = pkgs.nixVersions.latest;
      };
      nixpkgs = {
        config = {
          allowUnfree = true;
        };
      };

      security = {
        polkit.enable = true;
        #sudo.wheelNeedsPassword = false;
      };

      programs.gnupg.agent = {
        enable = true;
        enableSSHSupport = true;
      };

      # Timezone and locale
      time.timeZone = "${config.variables.timezone}";
      i18n.defaultLocale = "${config.variables.locale}";
      i18n.extraLocaleSettings = {
        LC_ADDRESS = "${config.variables.locale}";
        LC_IDENTIFICATION = "${config.variables.locale}";
        LC_MEASUREMENT = "${config.variables.locale}";
        LC_MONETARY = "${config.variables.locale}";
        LC_NAME = "${config.variables.locale}";
        LC_NUMERIC = "${config.variables.locale}";
        LC_PAPER = "${config.variables.locale}";
        LC_TELEPHONE = "${config.variables.locale}";
        LC_TIME = "${config.variables.locale}";
      };
      system.stateVersion = "25.11";
    };
}
