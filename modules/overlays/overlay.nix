{ inputs, ... }:
{
  flake = {
    overlays.default =
      final: prev:
      let
        system = final.stdenv.hostPlatform.system;
        pkg = input: name: inputs.${input}.packages.${system}.${name};

        localPkgs = import ../../pkgs {
          pkgs = final;
          inherit inputs;
        };
      in
      localPkgs
      // {
        wl-clipboard = prev.wl-clipboard-rs;
        ghostty = pkg "ghostty" "default";
        niri = pkg "niri" "default";
        neovim = pkg "vimmax" "default";
        lan-mouse = pkg "lan-mouse" "default";

        # loupe = prev.loupe.overrideAttrs (oldAttrs: {
        #   patches = (oldAttrs.patches or [ ]) ++ [
        #     ./patches/43-18-aspect-ratio.patch
        #   ];
        # });
      };

    nixosModules.overlays = {
      nixpkgs.overlays = [ inputs.self.overlays.default ];
    };
  };
}
