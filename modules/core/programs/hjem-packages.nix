{
  exo.core =
    { pkgs, ... }:
    {
      hj.packages = with pkgs; [
        eza
        lsof
        fd
        jq
        tldr
        wget
        unzip
        ripgrep
        killall
        isd # TUI systemd
        nap # Snippets
        scooter # search and replace
        mcat
      ];
    };
}
