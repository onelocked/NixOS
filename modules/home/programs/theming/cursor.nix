{
  flake.modules.homeManager.cursor =
    { pkgs, ... }:
    {
      home = {
        packages = with pkgs; [
          bareblood_cursor
          hand-of-evil
        ];
        pointerCursor = {
          gtk.enable = true;
          x11.enable = true;
          package = pkgs.bibata-cursors;
          name = "Bibata-Modern-Ice";
        };
      };
    };
}
