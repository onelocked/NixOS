{
  flake.homeModules.cli =
    { pkgs, lib, ... }:
    {
      home.shellAliases =
        let
          _ = lib.getExe;
        in
        {
          dots = "cd ~/NixOS";
          ping = "${_ pkgs.gping}";
          cat = "bat";
          zip = "${_ pkgs.zip}";
          ll = "${_ pkgs.eza} -l --icons --git -a";
          gtop = "${_ pkgs.amdgpu_top} --dark";
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
