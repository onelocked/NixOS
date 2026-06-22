{
  ff.vimmax = {
    url = "github:onelocked/vimmax";
    inputs = {
      flake-parts.follows = "flake-parts";
      nixpkgs.follows = "nixpkgs";
      systems.follows = "systems";
    };
  };
  exo.core = {
    forte.neovim = {
      enable = true;
      defaultEditor = true;
      desktopEntry = true;
    };
    forte.persist = {
      home.directories = [
        ".local/share/nvim" # data directory
        ".local/state/nvim" # persistent session info
        ".supermaven"
        ".local/share/supermaven"
      ];
    };
  };
  exo.skeleton =
    {
      lib,
      inputs',
      config,
      ...
    }:
    let
      cfg = config.forte.neovim;
      theme = config.forte.theme.variant;
      mimeType = [
        "text/english"
        "text/plain"
        "text/x-makefile"
        "text/x-c++hdr"
        "text/x-c++src"
        "text/x-chdr"
        "text/x-csrc"
        "text/x-java"
        "text/x-moc"
        "text/x-pascal"
        "text/x-tcl"
        "text/x-tex"
        "application/x-shellscript"
        "text/x-c"
        "text/x-c++"
      ];
    in
    {
      config =
        lib.mkIf cfg.enable
        <| lib.mkMerge [
          {
            hj.packages = [ cfg.package ];
          }
          (lib.mkIf cfg.defaultEditor {
            environment.sessionVariables = {
              EDITOR = "nvim";
              VISUAL = "nvim";
            };
          })
          (lib.mkIf cfg.desktopEntry {
            forte.xdg.desktopEntries = {
              "nvim" = {
                name = "Neovim";
                noDisplay = true;
                genericName = "Text Editor";
                comment = "Edit text files";
                exec = "nvim %F";
                terminal = true;
                type = "Application";
                icon = "nvim";
                startupNotify = false;
                inherit mimeType;
                settings = {
                  TryExec = "nvim";
                };
              };
            };
            xdg.mime.defaultApplications =
              mimeType |> map (mime: lib.nameValuePair mime [ "nvim.desktop" ]) |> lib.listToAttrs;
          })
        ];
      options.forte.neovim = {
        enable = lib.mkEnableOption "neovim";
        defaultEditor = lib.mkEnableOption "defaultEditor";
        desktopEntry = lib.mkEnableOption "desktopEntry";
        package = lib.mkOption {
          type = lib.types.package;
          default = inputs'.vimmax.packages.default.extend { vimmax.theme = theme; };
          defaultText = "default package for neovim";
        };
      };
    };
}
