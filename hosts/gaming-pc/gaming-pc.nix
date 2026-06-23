{ config, lib, ... }:
{
  exo.configurations = {
    gaming-pc = {
      user = "onelock";
      hardware = "gaming-pc";
      modules = [ config.exo.mods.desktop ];
      extraConfig = {
        forte.rtp-audio.enable = true;
        forte.gaming.enable = true;
        forte.vesktop.enable = lib.mkForce false;
        forte.lan-mouse.enable = true;
        services.sunshine = {
          enable = true;
          autoStart = true;
        };
        programs.spicetify.enable = lib.mkForce false;

        users.users.onelock.openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICM7ifW7zlpT8VeWOgCpKSAdnHr4vgIzrcyId/RQ822J gaming-pc"
        ];
        services.openssh = {
          enable = true;
          settings = {
            PermitRootLogin = "no";
            PasswordAuthentication = false;
            PermitEmptyPasswords = false;
          };
        };
      };
    };
  };
}
