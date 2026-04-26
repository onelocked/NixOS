{ self, ... }:
{
  ff = {
    nixpkgs.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.xz";
    flake-compat.url = "github:NixOS/flake-compat";
    systems.url = "github:nix-systems/x86_64-linux";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  m.default =
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
          extra-substituters = [ "https://bazinga.cachix.org" ];
          extra-trusted-public-keys = [ "bazinga.cachix.org-1:WI9TV6l0gBVhcfY7OQM5zWqYmESIarKME0fjVN6yDYU=" ];
          experimental-features = [
            "nix-command"
            "flakes"
            "pipe-operators"
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
