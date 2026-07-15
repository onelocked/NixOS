{
  exo.core =
    {
      lib,
      hostName,
      config,
      constants,
      ...
    }:
    let
      cfg = config.forte.openssh;
    in
    {
      config = lib.mkMerge [
        (lib.mkIf cfg.enable {
          services.openssh = {
            enable = true;
            hostKeys = [
              {
                path = "/persist/etc/ssh/ssh_host_ed25519_key";
                type = "ed25519";
              }
              {
                path = "/persist/etc/ssh/ssh_host_rsa_key";
                type = "rsa";
                bits = 4096;
              }
            ];
            settings = {
              PermitRootLogin = "no";
              PasswordAuthentication = false;
              PermitEmptyPasswords = false;
            };
          };
          users.users.onelock.openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICM7ifW7zlpT8VeWOgCpKSAdnHr4vgIzrcyId/RQ822J gaming-pc"
          ];
          # set permissions
          systemd.tmpfiles.settings.preservation = {
            "${config.hj.directory}/.ssh".d = lib.mkForce {
              user = constants.username;
              group = "users";
              mode = "0700";
            };
          };
        })
        (lib.mkIf (hostName == "mini-pc") {
          forte.persist = {
            home = {
              directories = [
                ".ssh"
                ".local/share/.gnupg"
              ];
            };
          };
          hj.files.".ssh/config".text = # bash
            ''
              Host Raspberry
                User onelock
                HostName 192.168.1.239
              Host gitea.onelock.org
                Port 2222
                IdentitiesOnly yes
                User git
                HostName gitea.onelock.org
                IdentityFile ~/.ssh/id_ed25519_gitea
              Host github.com
                IdentitiesOnly yes
                User git
                HostName github.com
                IdentityFile ~/.ssh/id_ed25519_github
              Host router
                User root
                HostName 192.168.1.1
            '';
        })
      ];
      options.forte.openssh.enable = lib.mkEnableOption null;
    };
}
