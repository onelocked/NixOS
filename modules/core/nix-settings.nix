{
  ff = {
    nixpkgs.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.xz";
    flake-compat.url = "github:NixOS/flake-compat";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  m.default =
    {
      pkgs,
      lib,
      constants,
      ...
    }:
    let
      inherit (constants) stateVersion username;
    in
    {
      forte.xdg.desktopEntries."nixos-manual".noDisplay = true;
      system = { inherit stateVersion; };
      environment.systemPackages = with pkgs; [
        nix-output-monitor
        nix-tree
        nix-update
        nix-init
        nix-melt
      ];
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

      programs.fish.shellAbbrs = {
        nb = "nom build";
        nd = "nom develop";
        nr = "nix run";
        nf = "nix run .#flake-update";
        wf = "nix run .#write-flake . --offline";
        ws = "nix run .#write-sources . --offline";
      };
    };
  perSystem =
    { pkgs, ... }:
    {
      apps.flake-update = {
        meta.description = "Update flake inputs interactively";
        program = pkgs.writeShellApplication {
          name = "flake-update";
          runtimeInputs = with pkgs; [
            gum
            nix
            jq
            git
          ];
          text = # bash
            ''
              # Fetch inputs from flake metadata
              inputs=$(nix flake metadata --json 2>/dev/null | jq -r '.locks.nodes.root.inputs | keys[]')

              if [[ -z "$inputs" ]]; then
                gum style --foreground 196 "No inputs found. Are you in a flake directory?"
                exit 1
              fi

              # Let user pick inputs with gum
              gum style \
                --border normal \
                --border-foreground 99 \
                --padding "0 1" \
                --bold \
                "Select inputs to update"

              selected=$(echo "$inputs" | gum filter \
                --no-limit \
                --placeholder "Type to search inputs..." \
                --prompt "▸ " \
                --header "Tab to select, Enter to confirm" \
                --header.foreground 243)

              if [[ -z "$selected" ]]; then
                gum style --foreground 243 "Nothing selected. Exiting."
                exit 0
              fi

              # Confirm
              echo
              gum style --foreground 99 --bold "Will update:"
              echo "$selected" | while read -r input; do
                gum style --foreground 255 "  • $input"
              done
              echo

              if ! gum confirm "Proceed with update?"; then
                gum style --foreground 243 "Aborted."
                exit 0
              fi

              # Update each input individually and commit
              echo "$selected" | while read -r input; do
                gum spin \
                  --spinner dot \
                  --title "Updating $input..." \
                  -- nix flake update "$input"

                git add flake.lock

                if git diff --cached --quiet; then
                  gum style --foreground 243 "  ~ $input: no changes, skipping commit"
                else
                  git commit -m "$input: flake update input"
                  gum style --foreground 82 --bold "  ✓ $input committed"
                fi
              done

              echo
              gum style --foreground 82 --bold "Done!"
            '';
        };
      };
    };
}
