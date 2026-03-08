{
  inputs,
  self,
  ...
}:
{
  flake.modules.nixos.default =
    { pkgs, config, ... }:
    {
      imports = [ inputs.sops-nix.nixosModules.sops ];
      environment.systemPackages = with pkgs; [
        sops
      ];
      sops.defaultSopsFile = ../../../secrets/gemini.yaml;
      sops.age.keyFile = self.variables.homedir + "/.config/sops/age/keys.txt";
      sops.age.generateKey = true;
      sops.secrets.gemini = {
        owner = "onelock";
        format = "yaml";
        sopsFile = config.sops.defaultSopsFile;
      };
    };
}
