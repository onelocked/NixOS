{
  inputs,
  ...
}:
let
  baseBtopConf = {
    vim_keys = true;
    rounded_corners = true;
    proc_tree = false;
    show_gpu_info = "on";
    show_uptime = true;
    show_coretemp = true;
    theme_background = false;
    cpu_single_graph = true;
    show_disks = true;
    show_swap = true;
    swap_disk = false;
    use_fstab = false;
    only_physical = false;
    shown_boxes = "cpu mem net proc gpu0";
    gpu_mirror_graph = false;
  };
in
{
  flake.modules.nixos.btop =
    { pkgs, ... }:
    {
      hj.packages = [
        (inputs.wrappers.wrappers.btop.wrap {
          inherit pkgs;
          package = pkgs.btop.override {
            rocmSupport = pkgs.config.rocmSupport or false;
          };
          settings = baseBtopConf // {
            color_theme = "noctalia";
          };
        })
      ];
    };
}
