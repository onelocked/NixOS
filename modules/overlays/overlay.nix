{ inputs, ... }:
{
  flake.modules.nixos.overlays = {
    nixpkgs.overlays = [ inputs.self.overlays.default ];
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
      loupe = getPkg "derivations" "loupe";
      amdgpu_top = getPkg "derivations" "amdgpu_top";
    };
}
