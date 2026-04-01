{
  flake.modules.homeManager.worktrunk =
    { pkgs, lib, ... }:
    {
      home.packages = [ pkgs.worktrunk ];
      programs = {
        fish.interactiveShellInit = ''
          ${lib.getExe pkgs.worktrunk} config shell init fish | source
        '';
      };
    };
}
