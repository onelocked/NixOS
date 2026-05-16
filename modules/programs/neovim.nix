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
    { inputs', ... }:
    {
      hj = {
        packages = [ inputs'.vimmax.packages.default ];
        environment.sessionVariables = {
          EDITOR = "nvim";
          VISUAL = "nvim";
        };
      };

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
    };
}
