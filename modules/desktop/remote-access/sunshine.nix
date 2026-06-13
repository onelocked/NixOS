{ inputs, ... }:
{
  exo.mods.desktop =
    { self', ... }:
    {
      services.sunshine = {
        package = self'.packages.sunshine;
        capSysAdmin = false;
        autoStart = false;
        openFirewall = true;
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
