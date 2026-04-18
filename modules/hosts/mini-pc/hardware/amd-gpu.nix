{
  m.hardware-mini-pc =
    { pkgs, ... }:
    {
      nixpkgs.config.rocmSupport = true;
      environment.systemPackages = with pkgs; [ rocmPackages.amdsmi ];
      hardware.amdgpu = {
        opencl.enable = true;
      };
    };
}
