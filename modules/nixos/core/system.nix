{ inputs, self, ... }:
{
  flake.modules.nixos.core =
    { pkgs, lib, ... }:
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
      nixpkgs.overlays = [
        (
          final: prev:
          import ../../../pkgs {
            pkgs = final;
            inherit inputs;
          }
        )
      ];
      nixpkgs = {
        hostPlatform = lib.mkDefault "x86_64-linux";
        config = {
          allowUnfree = true;
        };
      };

      security = {
        polkit.enable = true;
      };

      programs.gnupg.agent = {
        enable = true;
        enableSSHSupport = true;
      };

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
