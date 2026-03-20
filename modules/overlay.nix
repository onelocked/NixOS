{ inputs, self, ... }:
{
  flake.modules.nixos.overlays = {
    nixpkgs.overlays = [
      self.overlays.default
    ];
  };

  flake.overlays.default =
    final: prev:
    let
      system = final.stdenv.hostPlatform.system;
      getPkg = input: inputs.${input}.packages.${system}.default;

    in
    {
      wl-clipboard = prev.wl-clipboard-rs;

      niri = getPkg "niri";
    };
}
