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
      extraConfig = {
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
      };
    };
  };
}
