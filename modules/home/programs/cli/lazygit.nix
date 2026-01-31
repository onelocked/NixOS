{ self, ... }:
{
  flake.modules.homeManager.cli =
    { pkgs, ... }:
    {
      home.shellAliases = {
        lg = "lazygit";
      };
      programs.lazygit = {
        enable = true;
        enableNushellIntegration = true;
      };
      home = {
        packages = with pkgs; [
          delta
          gh-dash
        ];
        file = {
          ".gitconfig".text = ''
            [user]
            	name = onelocked
            	email = ${self.variables.email}

            [core]
                pager = delta

            [interactive]
                diffFilter = delta --color-only
            [delta]
                navigate = true  # use n and N to move between diff sections
                dark = true      # or light = true, or omit for auto-detection
                line-numbers = true
                hyperlinks = true

            [merge]
                conflictStyle = zdiff3

            [diff]
                colorMoved = default
          '';
        };
      };
      programs.git = {
        enable = true;
        settings = {
          core.editor = "$EDITOR";
          init.defaultBranch = "main";
          advice.objectNameWarning = false;
          pull.rebase = true;
          safe.directory = "/tmp"; # needed for ago.sh
        };
      };
    };
}
