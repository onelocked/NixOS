{
  flake.modules.homeManager.default =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        neovim
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
      ];
    };
}
