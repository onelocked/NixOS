{
  flake.nixosModules.desktop =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [ wl-clipboard-rs ];
    };
}
