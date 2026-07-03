{
  exo.core =
    { lib, config, ... }:
    let
      cfg = config.forte.nfs-share;
    in
    {
      config = lib.mkIf cfg.enable {
        services.nfs.server = {
          enable = true;
          exports = ''
            ${config.hj.directory}/Documents/NFS-Share  192.168.1.185/32(rw,sync,no_subtree_check,no_root_squash)
          '';
        };
        networking.firewall.allowedTCPPorts = [ 2049 ];
      };
      options.forte.nfs-share = {
        enable = lib.mkEnableOption "NFS share";
      };
    };
}
