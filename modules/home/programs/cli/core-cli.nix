{
  flake.modules.homeManager.cli =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        # Core CLI tools
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
