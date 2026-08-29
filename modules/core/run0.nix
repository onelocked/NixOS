{
  exo.core = {
    security = {
      sudo.enable = false;
      run0 = {
        enable = true;
        sudo-shim.enable = true;
        persistentAuth.enable = true;
      };
      polkit = {
        settings.Polkitd.ExpirationSeconds = 60;
        extraConfig = ''
          polkit.addRule(function(action, subject) {
            var isNixOsRebuild = (
              action.id == "org.freedesktop.systemd1.manage-units" ||
              action.id == "org.freedesktop.systemd1.reload-daemon"
            );

            if (isNixOsRebuild && subject.isInGroup("wheel")) {
              return polkit.Result.AUTH_ADMIN_KEEP;
            }
          });
        '';
      };
    };
  };
}
