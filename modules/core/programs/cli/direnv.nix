{
  exo.core =
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
      forte.persist.home.directories = [ ".local/share/direnv" ];
    };
}
