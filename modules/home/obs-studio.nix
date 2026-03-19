{ inputs, ... }:
{
  flake-file.inputs.extra-modules.url = "github:onelocked/extra-modules";
  flake.modules.homeManager = {
    obs-studio =
      { pkgs, ... }:
      {
        imports = [ inputs.extra-modules.homeManagerModules.obs-with-plugins ];
        programs.obs-with-plugins = {
          enable = true;
          systemd = true;
          plugins = with pkgs.obs-studio-plugins; [
            distroav
            obs-pipewire-audio-capture
          ];
        };
      };
  };
}
