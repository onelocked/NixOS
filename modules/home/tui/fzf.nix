{
  m.fzf = {
    custom.programs.fzf = {
      enable = true;
      colors = {
        "bg+" = "#2a2a3a";
        "fg+" = "#cfd3e7";
        "hl" = "#b8db8c";
        "hl+" = "#b8db8c";
        "info" = "#a8c8f0";
        "prompt" = "#c8b0e8";
        "pointer" = "#e8c4d8";
        "marker" = "#8fd4b5";
        "spinner" = "#7cb8d4";
        "header" = "#7d75c0";
        "border" = "#454545";
        "gutter" = "#2a2a3a";
      };
      defaultOptions = [
        "--height=50%"
        "--layout=reverse"
        "--border=rounded"
        "--padding=0,1"
        "--prompt=  "
        "--pointer= "
        "--marker=✓ "
        "--info=inline"
        "--scrollbar=▓"
        "--cycle"
      ];
    };
  };

  m.default =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.custom.programs.fzf;
      renderedColors =
        colors: lib.concatStringsSep "," (lib.mapAttrsToList (name: value: "${name}:${value}") colors);
    in
    {
      options.custom.programs.fzf = {
        enable = lib.mkEnableOption "fzf";
        package = lib.mkPackageOption pkgs "fzf" { };
        defaultOptions = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
        };
        colors = lib.mkOption {
          type = lib.types.attrsOf lib.types.str;
          default = { };
        };
      };
      config = lib.mkIf cfg.enable {
        environment.systemPackages = [ cfg.package ];
        environment.sessionVariables = {
          FZF_DEFAULT_OPTS =
            lib.concatStringsSep " " cfg.defaultOptions
            + lib.optionalString (cfg.colors != { }) " --color ${renderedColors cfg.colors}";
        };
        programs.fish.interactiveShellInit = "${lib.getExe cfg.package} --fish | source";
      };
    };
}
