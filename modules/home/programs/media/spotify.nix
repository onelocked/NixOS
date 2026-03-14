{ inputs, ... }:
{
  flake.modules.homeManager.spotify =
    { pkgs, ... }:
    {
      imports = [ inputs.spicetify-nix.homeManagerModules.default ];

      programs =
        let
          spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
        in
        {
          spicetify = {
            enable = true;
            theme = spicePkgs.themes.text;
            enabledExtensions = with spicePkgs.extensions; [
              adblock
              hidePodcasts
            ];
          };
        };
    };
}
