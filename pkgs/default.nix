{ pkgs, ... }:
let
  _ = pkgs.callPackage;
in
{
  apple-nerd-fonts = _ ./apple-nerd-fonts.nix { inherit pkgs; };
  wayland-ocr = _ ./wayland-ocr.nix { };
  niri-launcher = _ ./niri-launcher.nix { };
  mpv-wlpaste = _ ./mpv-wlpaste.nix { };
  amdgpu_top = _ ./amdgpu_top.nix { };
}
