{
  flake.homeModules.cli =
    { pkgs, ... }:
    {
      programs.btop = {
        enable = true;
        package = pkgs.btop-rocm;
        settings = {
          color_theme = "noctalia";
        };
      };
    };
}
