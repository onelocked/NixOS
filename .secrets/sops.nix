{ inputs, ... }:
{
  ff.sops-nix = {
    url = "github:Mic92/sops-nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  m.default =
    { pkgs, config, ... }:
    {
      imports = [ inputs.sops-nix.nixosModules.sops ];
      environment.systemPackages = with pkgs; [ sops ];
      sops = {
        defaultSopsFile = ./encrypted.yaml;
        age = {
          keyFile = config.hj.xdg.config.directory + "/sops/age/keys.txt";
          generateKey = true;
        };
      };
    };
}
