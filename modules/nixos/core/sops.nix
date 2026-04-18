{
  inputs,
  self,
  ...
}:
let
  inherit (self.variables) username homedir;
in
{
  flake-file.inputs.sops-nix = {
    url = "github:Mic92/sops-nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  m.default =
    { pkgs, config, ... }:
    {
      imports = [ inputs.sops-nix.nixosModules.sops ];
      environment.systemPackages = with pkgs; [ sops ];
      sops = {
        defaultSopsFile = ../../../secrets/encrypted.yaml;
        age = {
          keyFile = homedir + "/.config/sops/age/keys.txt";
          generateKey = true;
        };
        secrets.gemini = {
          key = "gemini";
          owner = username;
          format = "yaml";
          sopsFile = config.sops.defaultSopsFile;
        };
      };
    };
}
