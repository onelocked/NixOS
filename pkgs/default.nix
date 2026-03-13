{ pkgs, ... }:
let
  _ = pkgs.callPackage;
in
{
  wayland-ocr = _ ./wayland-ocr.nix { };
  niri-launcher = _ ./niri-launcher.nix { };
  mpv-wlpaste = _ ./mpv-wlpaste.nix { };
  grub-theme = _ ./grub-theme.nix { };
}
