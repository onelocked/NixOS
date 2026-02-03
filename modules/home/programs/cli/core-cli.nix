{ inputs, ... }:
{
  flake.modules.homeManager.cli =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        # Core CLI tools
        lsof
        tea
        fzf
        fd
        gh
        jq
        tldr
        wget
        unzip
        ripgrep
        libjxl
        dysk
        isd # TUI systemd
        microfetch
        ntfy-sh
        killall
        nap # Snippets

        opkssh
        radeontop
        gemini-cli
        inputs.opencode.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];
    };
}
