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
        nix-prefetch-scripts
        ntfy-sh
        killall
        nap # Snippets
        wayland-ocr
        launcher

        opkssh
        radeontop
        gemini-cli
        inputs.opencode.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];
    };
}
