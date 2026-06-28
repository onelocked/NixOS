{ config, ... }:
{
  exo.configurations = {
    gaming-pc = {
      user = "onelock";
      hardware = "gaming-pc";
      modules = with config.exo.mods; [
        desktop
        gaming
      ];
      extraConfig =
        { constants, ... }:
        {
          desktop.media.enable = false;
          forte.quickshell.enable = false;

          services.openssh = {
            enable = true;
            settings = {
              PermitRootLogin = "no";
              PasswordAuthentication = false;
              PermitEmptyPasswords = false;
            };
          };

          users.users.onelock.openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICM7ifW7zlpT8VeWOgCpKSAdnHr4vgIzrcyId/RQ822J gaming-pc"
          ];
          services.nfs.server.enable = true;

          services.nfs.server.exports = ''
            ${constants.homedir}/Documents/NFS-Share  192.168.1.185/32(rw,sync,no_subtree_check,no_root_squash)
          '';

          networking.firewall.allowedTCPPorts = [ 2049 ];
        };
    };
  };
}
