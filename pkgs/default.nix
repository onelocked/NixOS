{ pkgs, ... }:
let
  _ = pkgs.callPackage;
in
{
  apple-nerd-fonts = _ ./apple-nerd-fonts { inherit pkgs; };
  wayland-ocr = _ ./wayland-ocr { };
  niri-launcher = _ ./niri-launcher { };
  mpv-wlpaste = _ ./mpv-wlpaste { };
  # allCursors = (import ./cursors { inherit (pkgs) lib pkgs; });
}
