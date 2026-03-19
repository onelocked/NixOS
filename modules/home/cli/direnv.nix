{
  flake.modules.homeManager.direnv =
    { config, ... }:
    {
      programs.direnv = {
        enable = true;
        nix-direnv.enable = true;
        enableNushellIntegration = config.programs.nushell.enable or false;
        enableFishIntegration = config.programs.fish.enable or false;
        config = {
          global = {
            hide_env_diff = true;
          };
        };
      };
    };
}
