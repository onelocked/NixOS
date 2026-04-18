{
  m.worktrunk =
    { pkgs, lib, ... }:
    {
      hj.packages = [ pkgs.worktrunk ];
      programs = {
        fish.interactiveShellInit = ''
          ${lib.getExe pkgs.worktrunk} config shell init fish | source
        '';
      };
    };
}
