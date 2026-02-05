{ inputs, ... }:
{
  flake.modules.nixos.overlays = {
    nixpkgs.overlays = [
      (
        final: prev:
        let
          system = final.stdenv.hostPlatform.system;
          pkg = input: name: inputs.${input}.packages.${system}.${name};
        in
        {
          wl-clipboard = prev.wl-clipboard-rs;

          opencode = pkg "opencode" "default";
          ghostty = pkg "ghostty" "default";
          niri = pkg "niri-flake" "niri-unstable";
          neovim = pkg "onevix" "default";
          lan-mouse = pkg "lan-mouse" "default";
          xwayland-satellite = pkg "niri-flake" "xwayland-satellite-unstable";
          loupe = prev.loupe.overrideAttrs (oldAttrs: {
            patches = (oldAttrs.patches or [ ]) ++ [
              ./patches/43-18-aspect-ratio.patch
            ];
          });
        }
      )
    ];
  };
}
