{ inputs, ... }:
{
  flake-file.inputs = {
    extra-modules = {
      url = "github:onelocked/extra-modules";
      inputs.flake-parts.follows = "flake-parts";
    };
  };

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
