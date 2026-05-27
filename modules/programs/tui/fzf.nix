{
  m.fzf =
    { scheme, ... }:
    {
      forte.fzf = {
        enable = true;
        colors = with scheme.withHashtag; {
          "bg+" = base02;
          "fg+" = base07;
          "hl" = base0B;
          "hl+" = base0B;
          "info" = base0D;
          "prompt" = base0E;
          "pointer" = base12;
          "marker" = base0C;
          "spinner" = base15;
          "header" = base16;
          "border" = base01;
          "gutter" = base00;
        };
        defaultOptions = [
          "--height=50%"
          "--layout=reverse"
          "--border=double"
          "--preview-window=sharp"
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
      cfg = config.forte.fzf;
      renderedColors =
        colors: colors |> lib.mapAttrsToList (name: value: "${name}:${value}") |> lib.concatStringsSep ",";
    in
    {
      options.forte.fzf = {
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
        hj.packages = [ cfg.package ];
        hj.environment.sessionVariables = {
          FZF_DEFAULT_OPTS = lib.escapeShellArgs (
            cfg.defaultOptions ++ lib.optional (cfg.colors != { }) "--color=${renderedColors cfg.colors}"
          );
        };
        programs.fish.interactiveShellInit = "${lib.getExe cfg.package} --fish | source";
      };
    };
}
