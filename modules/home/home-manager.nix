{
  flake.modules.homeManager.onelock =
    { lib, ... }:
    {
      home.username = lib.mkDefault "onelock";
      home.homeDirectory = lib.mkDefault "/home/onelock";
      home.stateVersion = "25.11";
      home.sessionVariables = {
        EDITOR = "nvim";
      };
    };
}
