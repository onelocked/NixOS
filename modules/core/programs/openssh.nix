{
  exo.core =
    {
      lib,
      config,
      constants,
      ...
    }:
    let
      cfg = config.forte.openssh;
    in
    {
      config = lib.mkIf cfg.enable {
        services.openssh = {
          enable = true;
          settings = {
            PermitRootLogin = "no";
            PasswordAuthentication = false;
            PermitEmptyPasswords = false;
            KbdInteractiveAuthentication = false;
          };
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
        };
        users.users.${constants.username}.openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICkCeWsgSWc7pbDNm3rpBg6nmK7DEjI/6TrZaKR3ueOr shorekeeper"
        ];
        # set permissions
        systemd.tmpfiles.settings.preservation = {
          "${config.hj.directory}/.ssh".d = lib.mkForce {
            user = constants.username;
            group = "users";
            mode = "0700";
          };
        };
      };
      options.forte.openssh.enable = lib.mkEnableOption "openssh configuration" // {
        default = true;
      };
    };
}
