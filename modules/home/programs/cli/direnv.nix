{
  flake.modules.homeManager.cli = {
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
      enableBashIntegration = true;
      enableNushellIntegration = true;
      enableFishIntegration = true;
    };
    home.sessionVariables = {
      DIRENV_WARN_TIMEOUT = "60s";
    };
  };
}
