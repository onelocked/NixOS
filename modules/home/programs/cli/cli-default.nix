{
  flake.modules.homeManager.cli-default =
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
