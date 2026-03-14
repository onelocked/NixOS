{
  flake.modules.homeManager.default =
    { pkgs, lib, ... }:
    {
      home.shellAliases =
        let
          _ = lib.getExe;
        in
        with pkgs;
        {
          dots = "${pkgs.dott-tui}/bin/dott-tui";
          ping = "${_ gping}";
          cat = "${_ bat}";
          ff = "${_ fastfetch}";
          zip = "${_ zip}";
          ls = "${_ eza} -1h --color=auto --icons";
          la = "${_ eza} -1h --color=auto --icons -a";
          ll = "${_ eza} -lh --icons --git -a";
          gtop = "${_ amdgpu_top} --dark";
          gr = "cd (git rev-parse --show-toplevel)";
        };
      programs = {
        nix-your-shell = {
          enable = true;
          enableNushellIntegration = true;
          enableFishIntegration = true;
        };
        atuin = {
          enable = true;
          enableNushellIntegration = true;
          enableFishIntegration = true;
          settings = {
            search_mode = "fuzzy";
            filter_mode = "session-preload";
          };
        };
        pay-respects = {
          enable = true;
          enableFishIntegration = true;
          enableNushellIntegration = true;
        };
        zoxide = {
          enable = true;
          enableNushellIntegration = true;
          enableFishIntegration = true;
        };
        carapace = {
          enable = true;
          enableNushellIntegration = true;
          enableFishIntegration = true;
        };
      };
    };
}
