{
  flake.modules.nixos.core =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [ rocmPackages.amdsmi ];
      hardware.amdgpu = {
        opencl.enable = true;
      };
    };
}
