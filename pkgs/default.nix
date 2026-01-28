{
  pkgs,
  inputs,
  ...
}:
let
  _ = pkgs.callPackage;
in
{
  sddm-onelock = _ ./sddm-themes { theme = "onelock"; };
  apple-nerd-fonts = _ ./apple-nerd-fonts { inherit inputs; };
  win2xcur = _ ./win2xcur { };
  sunshine-xdg = _ ./sunshine/package.nix { };
  wayland-ocr = _ ./wayland-ocr { };
  allCursors = (import ./cursors { inherit (pkgs) lib pkgs; });
}
