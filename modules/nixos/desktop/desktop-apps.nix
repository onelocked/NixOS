{
  flake.nixosModules.desktop =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        mpv-wlpaste
        wayland-ocr
        niri-launcher
      ];
    };
}
