{
  flake.homeModules.fish =
    { pkgs, lib, ... }:
    {
      programs.fish = {
        enable = true;
        shellAliases =
          let
            _ = lib.getExe;
          in
          {
            dots = "cd ~/NixOS";
            ping = "${_ pkgs.gping}";
            cat = "bat";
            zip = "${_ pkgs.zip}";
            ll = "${_ pkgs.eza} -l --icons --git -a";
            gtop = "${_ pkgs.amdgpu_top} --dark";
          };
        functions = {
          __zoxide_interactive = ''
            set dir (zoxide query --interactive | string trim)

            if test -n "$dir"
              cd "$dir"
              y
              commandline -f repaint
            end
          '';
        };
        interactiveShellInit = ''
          bind Z __zoxide_interactive
        '';
      };
    };
}
