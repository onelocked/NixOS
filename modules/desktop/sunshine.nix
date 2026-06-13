{ inputs, ... }:
{
  m.sunshine =
    { self', ... }:
    {
      services.sunshine = {
        enable = true;
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
