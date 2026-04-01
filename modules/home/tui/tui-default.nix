{
  flake.modules.homeManager.default =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        isd # TUI systemd
        nap # Snippets
      ];
    };
}
