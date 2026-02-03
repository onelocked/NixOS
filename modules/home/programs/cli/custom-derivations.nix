{
  flake.modules.homeManager.pkgs =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        mpv-wlpaste
        wayland-ocr
        launcher
      ];
    };
}
