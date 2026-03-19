{
  inputs,
  self,
  ...
}:
{
  flake-file.inputs.sops-nix = {
    url = "github:Mic92/sops-nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.nixos.default =
    { pkgs, config, ... }:
    {
      imports = [ inputs.sops-nix.nixosModules.sops ];
      environment.systemPackages = with pkgs; [ sops ];
      sops = {
        defaultSopsFile = ../../../secrets/gemini.yaml;
        age.keyFile = self.variables.homedir + "/.config/sops/age/keys.txt";
        age.generateKey = true;
        secrets.gemini = {
          owner = "onelock";
          format = "yaml";
          sopsFile = config.sops.defaultSopsFile;
        };
      };
    };
}
