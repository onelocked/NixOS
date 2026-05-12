{
  m.hardware-mini-pc =
    {
      pkgs,
      self',
      lib,
      ...
    }:
    {
      nixpkgs.config.rocmSupport = true;
      environment = {
        systemPackages = with pkgs; [ rocmPackages.amdsmi ];
        shellAliases.gtop = "${lib.getExe pkgs.amdgpu_top} --dark";
      };
      hardware.amdgpu = {
        opencl.enable = true;
      };
      nixpkgs.overlays = [ (_: _: { amdgpu_top = self'.packages.amdgpu_top; }) ];
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
