{ inputs, ... }:
{
  flake-file.inputs.derivations.url = "git+file:///home/onelock/Development/Coding/derivations";
  flake.modules.homeManager = {
    obs-studio =
      { pkgs, ... }:
      {
        imports = [ inputs.derivations.homeManagerModules.obs-with-plugins ];
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
