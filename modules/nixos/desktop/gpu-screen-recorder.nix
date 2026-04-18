{
  m.desktop =
    { pkgs, lib, ... }:
    {
      environment.systemPackages = with pkgs; [ gpu-screen-recorder ];
      security.wrappers.gsr-kms-server = {
        source = lib.getExe' pkgs.gpu-screen-recorder "gsr-kms-server";
        capabilities = "cap_sys_admin+ep";
        owner = "root";
        group = "root";
      };
    };
}
