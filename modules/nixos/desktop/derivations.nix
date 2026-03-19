{ inputs, ... }:
{
  flake-file.inputs.derivations.url = "git+file:///home/onelock/Development/Coding/derivations";

  flake.modules.nixos.desktop =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        mpv-wlpaste
        wayland-ocr
        niri-launcher
      ];
      nixpkgs.overlays = [
        inputs.derivations.overlays.derivations
      ];
    };
}
