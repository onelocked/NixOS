{ inputs, ... }:
{
  ff.sops-nix = {
    url = "github:Mic92/sops-nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  exo.core =
    {
      pkgs,
      config,
      constants,
      ...
    }:
    {
      imports = [ inputs.sops-nix.nixosModules.sops ];
      environment.systemPackages = with pkgs; [ sops ];
      sops = {
        useSystemdActivation = true;
        defaultSopsFile = ./encrypted.yaml;
        age = {
          # NOTE: paths from persist are used, they need to exist before impermanence does its thing
          keyFile = "/persist${config.hj.directory}/.config/sops/age/keys.txt";
          # This will generate a new key if the key specified above does not exist
          generateKey = false;
        };
      };
      users.users.${constants.username}.extraGroups = [ config.users.groups.keys.name ];
      forte.persist.home.directories = [ ".config/sops" ];
    };
}
