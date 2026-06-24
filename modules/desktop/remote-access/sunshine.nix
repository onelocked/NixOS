{ inputs, ... }:
{
  exo.mods.desktop =
    {
      self',
      config,
      lib,
      hostName,
      ...
    }:
    {
      services.sunshine = {
        enable = config.desktop.remote-access.enable;
        autoStart = if hostName != "gaming-pc" then false else true;
        package = self'.packages.sunshine;
        capSysAdmin = false;
        openFirewall = true;
      };
      forte.persist.home = lib.mkIf config.services.sunshine.enable {
        directories = [ ".config/sunshine" ];
      };
    };
  ff.sunshine = {
    url = "github:Qubasa/nixpkgs/update_sunshine";
    flake = false;
  };
  perSystem =
    { pkgs, ... }:
    {
      packages.sunshine = pkgs.callPackage "${inputs.sunshine}/pkgs/by-name/su/sunshine/package.nix" { };
    };
}
