{ inputs, ... }:
{
  flake.modules.homeManager.jellyfin-desktop =
    { pkgs, ... }:
    {
      home.packages = [
        (inputs.wrappers.lib.wrapPackage {
          inherit pkgs;
          package = pkgs.jellyfin-desktop;
          flags = {
            "--platform" = "xcb";
          };
        })

      ];

    };
}
