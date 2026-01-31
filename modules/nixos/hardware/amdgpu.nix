{
  flake.modules.nixos.amdgpu =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [ rocmPackages.amdsmi ];
      hardware.amdgpu = {
        opencl.enable = true;
      };
    };
}
