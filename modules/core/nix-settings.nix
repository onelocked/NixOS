{
  ff = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-compat.url = "github:NixOS/flake-compat";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  exo.core =
    {
      pkgs,
      lib,
      constants,
      config,
      ...
    }:
    let
      inherit (constants) stateVersion username;
    in
    {
      forte.xdg.desktopEntries."nixos-manual".noDisplay = true;
      system = { inherit stateVersion; };
      environment.systemPackages = [ pkgs.nix-output-monitor ];
      nix = {
        channel.enable = false; # required for nix-shell -p to work, set it to true if needed
        optimise.automatic = true;
        package = pkgs.nixVersions.latest;
        settings = {
          allow-import-from-derivation = false;
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
        extraOptions = ''
          !include ${config.sops.secrets.nix_extra_config.path}
        '';
      };
      sops.secrets.nix_extra_config.owner = username;
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
              "apple_cursor"
            ];
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
}
