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
        isd # TUI systemd
        killall
        nap # Snippets
        nurl # Prefetch package hashes and generate the func

        opkssh
        opencode
      ];
    };
}
