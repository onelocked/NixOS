{
  flake.modules.nixos.default =
    {
      pkgs,
      lib,
      ...
    }:
    {
      environment.shellAliases =
        let
          _ = lib.getExe;
        in
        with pkgs;
        {
          ping = "${_ gping}";
          cat = "${_ bat}";
          ff = "${_ fastfetch}";
          zip = "${_ zip}";
          gtop = "${_ amdgpu_top} --dark";
          gr = "cd (git rev-parse --show-toplevel)";
          shot = "${wl-clipboard-rs}/bin/wl-paste | , silicon --language nix --to-clipboard --shadow-blur-radius 30 --pad-horiz 20 --pad-vert 20 --theme 'Visual Studio Dark+'";
        };

      hj.packages = [ pkgs.atuin ];
      programs = {
        # atuin = {
        #   enable = true;
        #   enableNushellIntegration = nushell;
        #   enableFishIntegration = fish;
        #   settings = {
        #     search_mode = "fuzzy";
        #     filter_mode = "session-preload";
        #   };
        # };
        pay-respects.enable = true;
        fish.interactiveShellInit =
          # let
          #   carapace = inputs.wrappers.wrappers.wrap
          # in
          # fish
          ''
            ${lib.getExe pkgs.pay-respects} fish | source
            ${lib.getExe pkgs.nix-your-shell} fish | source
            ${lib.getExe pkgs.carapace} _carapace fish | source

          '';
        zoxide = {
          enable = true;
          enableFishIntegration = true;
        };
        # carapace = {
        #   enable = true;
        #   enableNushellIntegration = nushell;
        #   enableFishIntegration = fish;
        # };
      };
    };
}
