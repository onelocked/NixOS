{ inputs, self, ... }:
{
  flake.modules.nixos.overlays = {
    nixpkgs.overlays = [
      self.overlays.default
      inputs.derivations.overlays.derivations
    ];
  };

  flake.overlays.default =
    final: prev:
    let
      system = final.stdenv.hostPlatform.system;
      getPkg = input: name: inputs.${input}.packages.${system}.${name};

      localPkgs = import ../../pkgs {
        pkgs = final;
        inherit inputs;
      };
    in
    localPkgs
    // {
      wl-clipboard = prev.wl-clipboard-rs;

      ghostty = getPkg "ghostty" "default";
      niri = getPkg "niri" "default";
      neovim = getPkg "vimmax" "default";
      lan-mouse = getPkg "lan-mouse" "default";
    };
}
