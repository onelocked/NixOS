{
  flake.modules.homeManager.cli = {
    programs.btop = {
      enable = true;
      settings = {
        color_theme = "noctalia";
      };
    };
  };
}
