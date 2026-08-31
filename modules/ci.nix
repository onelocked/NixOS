{
  perSystem =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    {
      options.remotePackages = lib.mkOption {
        type = lib.types.lazyAttrsOf lib.types.package;
        default = { };
        description = "Packages to build and cache remotely";
      };

      config.packages = config.remotePackages;

      config.apps.list-remote-packages = {
        type = "app";
        program = lib.getExe (
          pkgs.writeShellScriptBin "list-remote-packages" ''
            echo "${builtins.attrNames config.remotePackages |> lib.concatLines |> lib.trim}"
          ''
        );
      };
    };
}
