{
  exo.core =
    {
      lib,
      config,
      hostName,
      ...
    }:
    let
      cfg = config.forte.ssh-config;
    in
    {
      config = lib.mkIf cfg.enable {
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
      };
      options.forte.ssh-config = {
        enable = lib.mkEnableOption null // {
          default = if hostName != "gaming-pc" then true else false;
        };
      };
    };
}
