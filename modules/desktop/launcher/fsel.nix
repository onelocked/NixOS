{
  m.default =
    {
      lib,
      birdee,
      pkgs,
      self',
      config,
      ...
    }:
    let
      cfg = config.forte.fsel;
      tomlFormat = pkgs.formats.toml { };
    in
    {
      options.forte.fsel = {
        enable = lib.mkEnableOption "fsel";
        settings = lib.mkOption {
          inherit (tomlFormat) type;
          default = { };
          description = "Options to go into fsel's toml config";
        };
        package = lib.mkOption {
          type = lib.types.package;
          default = birdee.lib.wrapPackage (
            { config, ... }:
            {
              inherit pkgs;
              package = self'.packages.fsel;
              runtimePkgs = [ pkgs.app2unit ];
              flags = {
                "--config" = config.constructFiles.generatedConfig.path;
              };
              constructFiles.generatedConfig = {
                relPath = "config.toml";
                builder = ''mkdir -p "$(dirname "$2")" && cp ${tomlFormat.generate "config.toml" cfg.settings} "$2"'';
              };
            }
          );
        };
      };
    };
  envoy.fsel.github = "Mjoyufull/fsel";
  perSystem =
    { pkgs, envoy, ... }:
    {
      packages.fsel = pkgs.rustPlatform.buildRustPackage (finalAttrs: {
        inherit (envoy.fsel) pname version src;
        cargoHash = "sha256-G1wfue1Q+3NMH/5NqPVKeO0NpU0WJlwWkh51r3TM5IM=";
        doCheck = false;
      });
    };
}
