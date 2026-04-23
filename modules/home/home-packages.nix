{
  m.default =
    { pkgs, ... }:
    {
      hj.packages = with pkgs; [
        eza
        lsof
        fzf
        fd
        gh
        jq
        tldr
        wget
        unzip
        ripgrep
        killall
        # Coreutils rewrite in rust
        uutils-coreutils-noprefix
        wl-clipboard

        isd # TUI systemd
        nap # Snippets
        scooter # search and replace
        silicon
        mcat
      ];
    };
}
