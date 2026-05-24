{
  m.hardware-mini-pc =
    {
      pkgs,
      lib,
      self',
      ...
    }:
    {
      environment = {
        systemPackages = with pkgs; [ rocmPackages.amdsmi ];
        shellAliases.gtop = "${lib.getExe self'.packages.amdgpu_top} --dark";
      };
      nixpkgs.config.rocmSupport = true;
      hardware.amdgpu.opencl.enable = true;
    };
  perSystem =
    { pkgs, ... }:
    {
      packages.amdgpu_top = pkgs.amdgpu_top.overrideAttrs (oldAttrs: {
        doCheck = false;
        cargoBuildFlags = (oldAttrs.cargoBuildFlags or [ ]) ++ [
          "--no-default-features"
          "--features"
          "tui,libamdgpu_top/libdrm_link"
        ];
      });
    };
}
