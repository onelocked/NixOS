{
  m.default =
    { pkgs, ... }:
    {
      hj.packages = with pkgs; [
        isd # TUI systemd
        nap # Snippets
      ];
    };
}
