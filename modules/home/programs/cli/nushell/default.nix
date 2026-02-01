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
          shellAliases = {
            nix-shell = "nix-shell --run nu";
            dots = "cd ~/NixOS";
            ping = "${lib.getExe pkgs.gping}";
            cat = "bat";
          };
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
