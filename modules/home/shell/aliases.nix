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
          ls = "${_ lla} --sort-dirs-first --no-dotfiles";
          la = "${_ lla} --sort-dirs-first";
          ll = "${_ lla} -S";
          gtop = "${_ amdgpu_top} --dark";
          gr = "cd (git rev-parse --show-toplevel)";
          shot = "${pkgs.wl-clipboard-rs}/bin/wl-paste | , silicon --language nix --to-clipboard --shadow-blur-radius 30 --pad-horiz 20 --pad-vert 20 --theme 'Visual Studio Dark+'";
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
