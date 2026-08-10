{
  tack.inputs.vimmax = "gh:onelocked/vimmax";
  exo.mods.neovim = {
    forte.neovim.enable = true;
    forte.persist = {
      home.directories = [
        ".local/share/nvim" # data directory
        ".local/state/nvim" # persistent session info
        ".supermaven"
        ".local/share/supermaven"
        ".local/share/firenvim"
      ];
    };
  };
  exo.skeleton =
    {
      lib,
      inputs',
      config,
      theme,
      ...
    }:
    let
      cfg = config.forte.neovim;
    in
    {
      config = lib.mkIf cfg.enable {
        hj.packages = [ cfg.package ];
        environment.sessionVariables = {
          EDITOR = "nvim";
          VISUAL = "nvim";
        };
      };
      options.forte.neovim = {
        enable = lib.mkEnableOption "neovim";
        package = lib.mkOption {
          type = lib.types.package;
          default = inputs'.vimmax.packages.default.extend { vimmax.theme = theme; };
          defaultText = "default package for neovim";
        };
      };
    };

  exo.mods.desktop =
    { config, lib, ... }:
    let
      cfg = config.forte.neovim;
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
      config = lib.mkIf cfg.enable {
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
      };
    };
}
