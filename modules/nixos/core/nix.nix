{ self, lib, ... }:
{
  flake-file.inputs = {
    extra-modules.url = "github:onelocked/extra-modules";
    nixpkgs.url = lib.mkForce "";
    nixpkgs.follows = "extra-modules/nixpkgs";
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
          trusted-users = [ username ];
          # Binary Cache
          substituters = [
            "https://cachix.cachix.org"
            "https://onelock.cachix.org"
          ];
          trusted-public-keys = [
            "cachix.cachix.org-1:eWNHQldwUO7G2VkjpnjDbWwy4KQ/HNxht7H4SSoMckM="
            "onelock.cachix.org-1:Wyy9XrWqFKcPxkZXQg5yZXtsbKTbkaga44UWRJfgqEg="
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
              "steam"
              "steam-unwrapped"
            ];
        };
      };
    };
}
