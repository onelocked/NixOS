{
  flake.modules.homeManager.default =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
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
        opkssh
        # Coreutils rewrite in rust
        uutils-coreutils-noprefix
        wl-clipboard-rs
      ];
    };
}
