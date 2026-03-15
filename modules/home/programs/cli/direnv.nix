{
  flake.modules.homeManager.direnv = {
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
      enableBashIntegration = true;
      enableNushellIntegration = true;
      enableFishIntegration = true;
      config = {
        global = {
          hide_env_diff = true;
        };
      };
    };
  };
}
