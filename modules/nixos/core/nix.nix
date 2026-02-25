{ self, ... }:
{
  flake.nixosModules.core =
    { pkgs, lib, ... }:
    {
      nix = {
        settings = {
          trusted-users = [
            "root"
            self.variables.username
          ];
          auto-optimise-store = true;
          substituters = [
            "https://cache.nixos.org/"
            "https://cachix.cachix.org"
          ];
          trusted-public-keys = [
            "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
            "cachix.cachix.org-1:eWNHQldwUO7G2VkjpnjDbWwy4KQ/HNxht7H4SSoMckM="
          ];
          experimental-features = [
            "nix-command"
            "flakes"
          ];
          extra-substituters = [ "https://onelock.cachix.org" ];
          extra-trusted-public-keys = [ "onelock.cachix.org-1:Wyy9XrWqFKcPxkZXQg5yZXtsbKTbkaga44UWRJfgqEg=" ];

          use-xdg-base-directories = true;
          warn-dirty = false;
          keep-outputs = true;
          keep-derivations = true;
        };
        optimise.automatic = true;
        package = pkgs.nixVersions.latest;
      };
      nixpkgs = {
        hostPlatform = lib.mkDefault "x86_64-linux";
        config = {
          allowUnfree = false;
          allowUnfreePredicate =
            pkg:
            builtins.elem (lib.getName pkg) [
              "parsec-bin"
              "ndi-6"
            ];
        };
      };
    };
}
