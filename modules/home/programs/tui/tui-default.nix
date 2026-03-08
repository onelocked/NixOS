{
  flake.modules.homeManager.tui-default =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        isd # TUI systemd
        nap # Snippets
      ];
    };
}
