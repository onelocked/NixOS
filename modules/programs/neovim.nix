{
  ff.vimmax = {
    url = "github:onelocked/vimmax";
    inputs = {
      flake-parts.follows = "flake-parts";
      nixpkgs.follows = "nixpkgs";
      systems.follows = "systems";
    };
  };
  m.neovim =
    { inputs', config, ... }:
    let
      theme = config.forte.theme.variant;
    in
    {
      forte.neovim = {
        enable = true;
        defaultEditor = true;
        desktopEntry = true;
        package = inputs'.vimmax.packages.default.override { inherit theme; };
      };
    };
  m.default =
    {
      lib,
      inputs',
      config,
      ...
    }:
    let
      cfg = config.forte.neovim;
    in
    {
      config = lib.mkIf cfg.enable (
        lib.mkMerge [
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
                settings = {
                  TryExec = "nvim";
                };
              };
            };
          })
        ]
      );
      options.forte.neovim = {
        enable = lib.mkEnableOption "neovim";
        defaultEditor = lib.mkEnableOption "defaultEditor";
        desktopEntry = lib.mkEnableOption "desktopEntry";
        package = lib.mkOption {
          type = lib.types.package;
          default = inputs'.vimmax.packages.default;
          defaultText = "default package for neovim";
        };
      };
    };
}
