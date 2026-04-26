{ inputs, ... }:
{
  m.worktrunk =
    { pkgs, lib, ... }:
    let
      tomlFormat = pkgs.formats.toml { };
    in
    {
      programs.fish.interactiveShellInit = "${lib.getExe pkgs.worktrunk} config shell init fish | source ";
      hj.packages = [ pkgs.worktrunk ];
      nixpkgs.overlays = [
        (_: prev: {
          worktrunk = inputs.wrappers.lib.wrapPackage {
            pkgs = prev;
            package = prev.worktrunk;
            env.WORKTRUNK_CONFIG_PATH = tomlFormat.generate "worktrunk-config.toml" {
              merge = {
                squash = false;
                commit = false;
                rebase = true;
                remove = false;
                verify = true;
                ff = true;
              };
              skip-shell-integration-prompt = true;
              skip-commit-generation-prompt = true;
            };
          };
        })
      ];
    };
}
