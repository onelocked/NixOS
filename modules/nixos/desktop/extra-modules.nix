{ inputs, ... }:
{
  flake-file.inputs.extra-modules.url = "github:onelocked/extra-modules";

  flake.modules.nixos.desktop =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        mpv-wlpaste
        wayland-ocr
        niri-launcher
      ];
      nixpkgs.overlays = [
        inputs.extra-modules.overlays.derivations
      ];
    };
}
