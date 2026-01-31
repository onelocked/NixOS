{
  flake.modules.homeManager.cli = {
    programs.fastfetch = {
      enable = true;
    };
    xdg.configFile."fastfetch/config.jsonc".source = ./config.jsonc;
  };
}
