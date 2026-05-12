{
  m.direnv =
    { config, ... }:
    {
      programs.direnv = {
        enable = true;
        nix-direnv.enable = true;
        enableFishIntegration = config.programs.fish.enable or false;
        settings = {
          global = {
            hide_env_diff = true;
          };
        };
      };
    };
}
