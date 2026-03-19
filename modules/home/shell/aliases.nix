{
  flake.modules.homeManager.default =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      fish = config.programs.fish.enable or false;
      nushell = config.programs.nushell.enable or false;
    in
    lib.mkIf (fish || nushell) {
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
          enableNushellIntegration = nushell;
          enableFishIntegration = fish;
        };
        atuin = {
          enable = true;
          enableNushellIntegration = nushell;
          enableFishIntegration = fish;
          settings = {
            search_mode = "fuzzy";
            filter_mode = "session-preload";
          };
        };
        pay-respects = {
          enable = true;
          enableFishIntegration = fish;
          enableNushellIntegration = nushell;
        };
        zoxide = {
          enable = true;
          enableNushellIntegration = nushell;
          enableFishIntegration = fish;
        };
        carapace = {
          enable = true;
          enableNushellIntegration = nushell;
          enableFishIntegration = fish;
        };
      };
    };
}
