{
  flake.modules.nixos.vesktop =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        vesktop
      ];
    };
}
