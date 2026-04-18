{ self, ... }:
{
  m.overlays = {
    nixpkgs.overlays = [
      self.overlays.default
    ];
  };
  flake.overlays.default = final: prev: {
    wl-clipboard = prev.wl-clipboard-rs;
  };
}
