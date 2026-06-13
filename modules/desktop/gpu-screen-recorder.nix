{
  exo.mods.desktop =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      cfg = config.forte.gpu-screen-recorder;
    in
    {
      config = lib.mkIf cfg.enable {
        environment.systemPackages = [ pkgs.gpu-screen-recorder ];
        security.wrappers.gsr-kms-server = {
          source = lib.getExe' pkgs.gpu-screen-recorder "gsr-kms-server";
          capabilities = "cap_sys_admin+ep";
          owner = "root";
          group = "root";
        };
      };
      options.forte.gpu-screen-recorder = {
        enable = lib.mkEnableOption "GPU Screen Recorder";
      };
    };
}
