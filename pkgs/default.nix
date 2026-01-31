{ pkgs, ... }:
let
  _ = pkgs.callPackage;
in
{
  sddm-onelock = _ ./sddm-themes { theme = "onelock"; };
  apple-nerd-fonts = _ ./apple-nerd-fonts { inherit pkgs; };
  sunshine-xdg = _ ./sunshine/package.nix { };
  # wayland-ocr = _ ./wayland-ocr { };
  # win2xcur = _ ./win2xcur { };
  # allCursors = (import ./cursors { inherit (pkgs) lib pkgs; });
}
