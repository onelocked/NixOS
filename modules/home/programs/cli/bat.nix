{
  flake.modules.homeManager.cli =
    { pkgs, ... }:
    {
      programs.bat = {
        enable = true;
        config = {
          theme = "TwoDark";
          style = "plain";
          paging = "never";
        };

        extraPackages = with pkgs.bat-extras; [
          batman
        ];
      };
      home.shellAliases = {
        man = "batman --paging=auto";
      };
    };
}
