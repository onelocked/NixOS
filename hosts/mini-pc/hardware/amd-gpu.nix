{
  exo.hardware.mini-pc =
    { self', ... }:
    {
      nixpkgs.config.rocmSupport = true;
      hardware.amdgpu.opencl.enable = true;
      hj.packages = [ self'.packages.amdgpu_top ];
    };
  perSystem =
    { pkgs, ... }:
    {
      packages.amdgpu_top = pkgs.amdgpu_top.overrideAttrs (old: {
        doCheck = false;
        cargoBuildFlags = (old.cargoBuildFlags or [ ]) ++ [
          "--no-default-features"
          "--features"
          "tui,libamdgpu_top/libdrm_link"
        ];
        nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ pkgs.makeWrapper ];
        postInstall = (old.postInstall or "") + ''
          makeWrapper $out/bin/amdgpu_top $out/bin/gtop \
            --add-flags '--dark'
        '';
      });
    };
}
