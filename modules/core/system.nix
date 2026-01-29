{
  flake.modules.nixos.core =
    {
      config,
      pkgs,
      inputs,
      outputs,
      ...
    }:
    {
      imports = [
        inputs.nix-index-database.nixosModules.nix-index
      ];
      # Nix Package Manager Settings
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
        overlays = builtins.attrValues outputs.overlays;
        config = {
          allowUnfree = true;
        };
      };

      security = {
        polkit.enable = true;
        #sudo.wheelNeedsPassword = false;
      };

      programs.nix-index-database.comma.enable = true;
      programs.gnupg.agent = {
        enable = true;
        enableSSHSupport = true;
      };

      # Timezone and locale
      time.timeZone = "${config.constants.timezone}";
      i18n.defaultLocale = "${config.constants.locale}";
      i18n.extraLocaleSettings = {
        LC_ADDRESS = "${config.constants.locale}";
        LC_IDENTIFICATION = "${config.constants.locale}";
        LC_MEASUREMENT = "${config.constants.locale}";
        LC_MONETARY = "${config.constants.locale}";
        LC_NAME = "${config.constants.locale}";
        LC_NUMERIC = "${config.constants.locale}";
        LC_PAPER = "${config.constants.locale}";
        LC_TELEPHONE = "${config.constants.locale}";
        LC_TIME = "${config.constants.locale}";
      };
      system.stateVersion = "25.11";
    };
}
