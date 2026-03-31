{
  flake.modules.nixos.default = {
    zramSwap = {
      enable = true;
      algorithm = "zstd";
      priority = 10;
      memoryPercent = 30;
    };
  };
}
