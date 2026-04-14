{ inputs, ... }:
{
  flake-file.inputs.spicetify-nix = {
    url = "github:Gerg-L/spicetify-nix";
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.systems.follows = "systems";
  };

  flake.modules.homeManager.spotify =
    { pkgs, ... }:
    let
      spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
    in
    {
      imports = [ inputs.spicetify-nix.homeManagerModules.default ];

      programs.spicetify = {
        enable = true;
        theme = spicePkgs.themes.text;
        customColorScheme = {
          accent = "c8b0e8";
          accent-active = "c5c0ff";
          accent-inactive = "454545";
          banner = "7d75c0";
          border-active = "c5c0ff";
          border-inactive = "272731";
          header = "787878";
          highlight = "454545";
          main = "131316";
          notification = "a8c8f0";
          notification-error = "f4a8b8";
          subtext = "8c92aa";
          text = "cfd3e7";
        };
        enabledExtensions = with spicePkgs.extensions; [
          adblock
          hidePodcasts
        ];
      };
    };
}
