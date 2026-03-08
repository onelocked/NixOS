{
  flake.modules.homeManager.vesktop =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        vesktop
      ];
    };
}
