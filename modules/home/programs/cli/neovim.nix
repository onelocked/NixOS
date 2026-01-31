{ inputs, ... }:
{
  flake.modules.homeManager.cli =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        inputs.onevix.packages.${stdenv.hostPlatform.system}.default
      ];
    };
}
