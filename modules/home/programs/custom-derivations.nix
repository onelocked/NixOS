{
  flake.homeModules.custom-derivations =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        mpv-wlpaste
        wayland-ocr
        niri-launcher
      ];
    };
}
