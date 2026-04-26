{ lib, config, ... }:
let
  topConfig = config;
  generated = import ../nvfetcher/generated.nix;

  srcTagKeys = [
    "github"
    "github_tag"
    "git"
    "gitlab"
    "pypi"
    "archpkg"
    "aur"
    "manual"
    "repology"
    "webpage"
    "httpheader"
    "openvsx"
    "vsmarketplace"
    "cmd"
    "container"
  ];
  fetchTagKeys = [
    "github"
    "pypi"
    "git"
    "url"
    "tarball"
    "gitlab"
    "docker"
  ];

  hasExactlyOneTag =
    tagKeys: attrs: lib.length (lib.intersectLists tagKeys (lib.attrNames attrs)) == 1;

  taggedAttrs =
    tagKeys: lib.types.addCheck (lib.types.attrsOf lib.types.anything) (hasExactlyOneTag tagKeys);

  sourceType = lib.types.submodule (
    { name, ... }:
    {
      freeformType = lib.types.attrsOf lib.types.anything;
      options = {
        src = lib.mkOption {
          type = taggedAttrs srcTagKeys;
          description = ''
            Version source for `${name}`. Must contain exactly one of:
            ${lib.concatStringsSep ", " srcTagKeys}.
            Modifier keys like `branch`, `regex`, `prerelease`, `include_regex`
            may be set alongside.
          '';
        };
        fetch = lib.mkOption {
          type = taggedAttrs fetchTagKeys;
          description = ''
            Fetcher for `${name}`. Must contain exactly one of:
            ${lib.concatStringsSep ", " fetchTagKeys}.
          '';
        };
      };
    }
  );
in
{
  options.nvfetcher.sources = lib.mkOption {
    type = lib.types.attrsOf sourceType;
    default = { };
    description = "nvfetcher source definitions, written to nvfetcher.toml.";
    example = lib.literalExpression ''
      {
        helix = {
          src.github = "helix-editor/helix";
          fetch.github = "helix-editor/helix";
        };
        nvfetcher-git = {
          src.git = "https://github.com/berberman/nvfetcher";
          fetch.github = "berberman/nvfetcher";
        };
      }
    '';
  };

  imports = [ (lib.mkAliasOptionModule [ "nv" ] [ "nvfetcher" "sources" ]) ];

  config = {
    m.default =
      { pkgs, ... }:
      {
        _module.args.nvfetcher = pkgs.callPackage generated { };
      };

    perSystem =
      { pkgs, ... }:
      let
        tomlFile = (pkgs.formats.toml { }).generate "nvfetcher.toml" topConfig.nvfetcher.sources;
      in
      {
        _module.args.nvfetcher = pkgs.callPackage generated { };
        apps.write-sources = {
          meta.description = "Run nvfetcher to generate sources";
          program = pkgs.writeShellApplication {
            name = "write-sources";
            runtimeInputs = [ pkgs.nvfetcher ];
            text = "nvfetcher -c ${tomlFile} -o nvfetcher ";
          };
        };
      };
  };
}
