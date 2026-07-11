{
  tack = {
    nixpkgs = "gh:nixos/nixpkgs/nixos-unstable";
    birdee = "gh:BirdeeHub/nix-wrapper-modules";
    disko = "gh:nix-community/disko";
    systems = "gh:nix-systems/x86_64-linux";
  };
  exo.core =
    {
      pkgs,
      lib,
      constants,
      config,
      ...
    }:
    {
      forte.xdg.desktopEntries."nixos-manual".noDisplay = true;
      system.stateVersion = "25.11";
      environment.systemPackages = [ pkgs.nix-output-monitor ];
      nix = {
        channel.enable = false; # required for nix-shell -p to work, set it to true if needed
        optimise.automatic = true;
        package = pkgs.nixVersions.latest;
        settings = {
          allow-import-from-derivation = false;
          trusted-users = [ constants.username ];
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
        extraOptions = "!include ${config.sops.secrets.nix_extra_config.path}";
      };
      sops.secrets.nix_extra_config.owner = constants.username;
      programs.nano.enable = lib.mkForce false;
      nixpkgs = {
        hostPlatform = lib.mkDefault "x86_64-linux";
        config = {
          allowUnfree = false;
          allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) config.forte.allowUnfree;
        };
      };

      programs.fish.shellAbbrs = {
        nb = "nom build";
        nd = "nom develop";
        nr = "nix run";
        nf = "nix run .#flake-update";
        wf = "nix run .#write-flake . --offline";
        ws = "nix run .#write-sources . --offline";
      };
    };
  exo.skeleton =
    { lib, ... }:
    {
      options.forte = {
        allowUnfree = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
        };
      };

    };
}
