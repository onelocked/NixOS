{
  flake.modules.homeManager.vicinae = {
    programs.vicinae = {
      enable = true;
      useLayerShell = true;
      systemd = {
        enable = true;
        autoStart = true;
      };
    };
  };
}
