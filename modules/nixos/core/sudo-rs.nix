{
  flake.modules.nixos.core = {
    security = {
      sudo.enable = false;
      sudo-rs = {
        enable = true;
        wheelNeedsPassword = true;
        execWheelOnly = true;
      };
      polkit.enable = true;
    };
  };
}
