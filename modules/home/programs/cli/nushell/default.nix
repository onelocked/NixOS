{
  flake.modules.homeManager.cli =
    { pkgs, lib, ... }:
    let
      definitionsPath = ./nufiles/definitions;
      definitionFiles = builtins.attrNames (builtins.readDir definitionsPath);
      sourceDefinitions = pkgs.lib.strings.concatMapStringsSep "\n" (
        file: "source ${definitionsPath}/${file}"
      ) definitionFiles;
    in
    {
      home.shell.enableNushellIntegration = true;
      programs = {
        nushell = {
          enable = true;
          extraConfig = ''
            $env.PATH ++= [ "~/.nix-profile/bin" ]
          '';
          configFile.text = ''
            source ${./nufiles/config.nu}
            source ${./nufiles/theme/catppuccin_mocha.nu}
            ${sourceDefinitions}
          '';
          envFile.text = ''
            $env.EDITOR = "nvim"
            $env.CARAPACE_BRIDGES = 'zsh,bash'
          '';
          shellAliases =
            let
              _ = lib.getExe;
            in
            {
              nix-shell = "nix-shell --run nu";
              dots = "cd ~/NixOS";
              ping = "${_ pkgs.gping}";
              cat = "bat";
              zip = "${_ pkgs.zip}";
              ll = "${_ pkgs.eza} -l --icons --git -a";
            };
        };
        atuin = {
          enable = true;
          enableNushellIntegration = true;
        };
        pay-respects = {
          enable = true;
          enableNushellIntegration = true;
        };
        zoxide = {
          enable = true;
          enableNushellIntegration = true;
        };
        carapace = {
          enable = true;
          enableNushellIntegration = true;
        };
      };
    };
}
