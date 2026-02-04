{ inputs, ... }:
{
  flake.modules.nixos.overlays = {
    nixpkgs.overlays = [
      (final: prev: {
        opencode = inputs.opencode.packages.${final.stdenv.hostPlatform.system}.default;
        ghostty = inputs.ghostty.packages.${final.stdenv.hostPlatform.system}.default;
        niri = inputs.niri-flake.packages.${final.stdenv.hostPlatform.system}.niri-unstable;
        neovim = inputs.onevix.packages.${final.stdenv.hostPlatform.system}.default;
        xwayland-satellite =
          inputs.niri-flake.packages.${final.stdenv.hostPlatform.system}.xwayland-satellite-unstable;
      })
    ];
  };
}
