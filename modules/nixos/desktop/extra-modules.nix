{ inputs, ... }:
{
  ff = {
    extra-modules = {
      url = "github:onelocked/extra-modules";
      inputs = {
        flake-parts.follows = "flake-parts";
        import-tree.follows = "import-tree";
        systems.follows = "systems";
      };
    };
  };

  m.desktop =
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
