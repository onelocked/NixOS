{
  flake.modules.homeManager.btop =
    { pkgs, ... }:
    {
      programs.btop = {
        enable = true;
        package = pkgs.btop;
        settings = {
          color_theme = "noctalia";
          vim_keys = true;
          rounded_corners = true;
          proc_tree = false;
          show_gpu_info = "on";
          show_uptime = true;
          show_coretemp = true;
        };
      };
    };
}
