{
  flake.modules.nixos.tui =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        isd # TUI systemd
        nap # Snippets
      ];
    };
}
