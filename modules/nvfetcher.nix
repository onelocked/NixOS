topLevel@{ lib, ... }:
let
  generated = import ../nvfetcher/generated.nix;
  injectArg =
    { pkgs, ... }:
    {
      _module.args.nvfetcher = pkgs.callPackage generated { };
    };

  # See: https://github.com/berberman/nvfetcher for the full list of source
  # and fetcher tags, plus modifier keys (branch, regex, prerelease, etc.).
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
    tagKeys:
    (lib.types.addCheck (lib.types.attrsOf lib.types.anything) (hasExactlyOneTag tagKeys))
    // {
      description = "attrs containing exactly one of: ${lib.concatStringsSep ", " tagKeys}";
    };

  # Map from src tag -> function building the inferred fetch entry.
  # Add new entries here when nvfetcher gains directly-fetchable source types.
  fetchInferenceMap = {
    github = src: { github = src.github; };
    github_tag = src: { github = src.github_tag; };
    pypi = src: { pypi = src.pypi; };
    git = src: { git = src.git; };
    gitlab = src: { gitlab = src.gitlab; };
  };

  inferFetch =
    src:
    let
      key = lib.findFirst (k: src ? ${k}) null (lib.attrNames fetchInferenceMap);
    in
    if key == null then null else fetchInferenceMap.${key} src;

  # Shorthand keys that must be stripped before serializing to TOML —
  # nvfetcher itself doesn't understand them.
  shorthandKeys = [
    "github"
    "gitlab"
    "codeberg"
    "srchut"
  ];
  stripShorthands = source: lib.filterAttrs (n: _: !lib.elem n shorthandKeys) source;

  sourceType = lib.types.submodule (
    { name, config, ... }:
    {
      freeformType = lib.types.attrsOf lib.types.anything;
      options = {
        github = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "Shorthand for GitHub sources. Sets src.git and fetch.github.";
        };
        gitlab = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "Shorthand for GitLab sources. Sets src.git and fetch.gitlab.";
        };
        codeberg = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "Shorthand for Codeberg sources. Sets src.git and fetch.git.";
        };
        srchut = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = ''
            Shorthand for SourceHut sources, given as `owner/repo` (no `~`).
            Sets src.git and fetch.git to `https://git.sr.ht/~owner/repo`.
          '';
        };
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
          # Default to {} so the inference branch below can override via mkDefault.
          # If neither inference nor user input populates this, the type check
          # will fire with a clear "exactly one of" message.
          default = { };
          description = ''
            Fetcher for `${name}`. Must contain exactly one of:
            ${lib.concatStringsSep ", " fetchTagKeys}.
            If omitted, it will be inferred from `src` if possible.
          '';
        };
      };
      config =
        let
          setShorthands = lib.filter (k: config.${k} != null) shorthandKeys;
        in
        lib.mkMerge [
          (lib.mkIf (config.github != null) {
            src.git = lib.mkDefault "https://github.com/${config.github}";
            fetch.github = lib.mkDefault config.github;
          })
          (lib.mkIf (config.gitlab != null) {
            src.git = lib.mkDefault "https://gitlab.com/${config.gitlab}";
            fetch.gitlab = lib.mkDefault config.gitlab;
          })
          (lib.mkIf (config.codeberg != null) {
            src.git = lib.mkDefault "https://codeberg.org/${config.codeberg}";
            fetch.git = lib.mkDefault "https://codeberg.org/${config.codeberg}";
          })
          (lib.mkIf (config.srchut != null) {
            src.git = lib.mkDefault "https://git.sr.ht/~${config.srchut}";
            fetch.git = lib.mkDefault "https://git.sr.ht/~${config.srchut}";
          })
          (lib.mkIf (setShorthands == [ ]) (
            let
              inferred = inferFetch config.src;
            in
            lib.mkIf (inferred != null) { fetch = lib.mkDefault inferred; }
          ))
        ];
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
        };
        nvfetcher-git = {
          src.git = "https://github.com/berberman/nvfetcher";
          fetch.github = "berberman/nvfetcher";
        };
        fuzzy-search = {
          github = "onelocked/fuzzy-search.yazi";
        };
      }
    '';
  };

  imports = [ (lib.mkAliasOptionModule [ "nv" ] [ "nvfetcher" "sources" ]) ];

  config = {
    m.default = injectArg;

    perSystem =
      { pkgs, ... }:
      let
        # `topLevel.config.…` (not perSystem `config`) because sources are
        # defined at the top level, not per-system.
        processedSources = lib.mapAttrs (_: stripShorthands) topLevel.config.nvfetcher.sources;
        tomlFile = (pkgs.formats.toml { }).generate "nvfetcher.toml" processedSources;
      in
      {
        imports = [ injectArg ];
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
