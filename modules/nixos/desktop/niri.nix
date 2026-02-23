{
  flake.nixosModules.desktop =
    { pkgs, ... }:
    {
      nix.settings = {
        extra-substituters = [ "https://niri.cachix.org" ];
        extra-trusted-public-keys = [ "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964=" ];
      };
      programs.niri = {
        enable = true;
        useNautilus = false;
      };
      programs.xwayland = {
        enable = true;
        package = pkgs.xwayland-satellite;
      };
    };
}
