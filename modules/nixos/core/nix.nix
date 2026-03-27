{ self, ... }:
{
  flake-file.inputs = {
    nixpkgs.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.xz";
  };

  flake.modules.nixos.default =
    { pkgs, lib, ... }:
    let
      inherit (self.variables) stateVersion username;
    in
    {
      system.stateVersion = stateVersion;
      nix = {
        optimise.automatic = true;
        package = pkgs.nixVersions.latest;
        settings = {
          trusted-users = [
            "root"
            username
          ];
          experimental-features = [
            "nix-command"
            "flakes"
          ];

          auto-optimise-store = true;
          use-xdg-base-directories = true;
          warn-dirty = false;
          keep-outputs = true;
          keep-derivations = true;

          # Binary Cache
          substituters = [
            "https://cache.nixos.org/"
            "https://cachix.cachix.org"
          ];
          trusted-public-keys = [
            "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
            "cachix.cachix.org-1:eWNHQldwUO7G2VkjpnjDbWwy4KQ/HNxht7H4SSoMckM="
          ];
          extra-substituters = [ "https://onelock.cachix.org" ];
          extra-trusted-public-keys = [ "onelock.cachix.org-1:Wyy9XrWqFKcPxkZXQg5yZXtsbKTbkaga44UWRJfgqEg=" ];
        };
      };
      programs.nano.enable = lib.mkForce false;
      nixpkgs = {
        hostPlatform = lib.mkDefault "x86_64-linux";
        config = {
          allowUnfree = false;
          allowUnfreePredicate =
            pkg:
            builtins.elem (lib.getName pkg) [
              "parsec-bin"
              "ndi-6"
              "spotify"
            ];
        };
      };
    };
}
