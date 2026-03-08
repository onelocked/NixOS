{ self, ... }:
{
  flake.modules.homeManager.cli =
    { pkgs, ... }:
    {
      programs.git =
        let
          inherit (self.variables) username email;
        in
        {
          enable = true;
          settings = {
            user = {
              name = username + "ed";
              email = email;
            };
            interactive = {
              diffFilter = "delta --color-only";
            };
            core = {
              editor = "$EDITOR";
              pager = "delta";
            };
            delta = {
              navigate = true;
              dark = true;
              line-numbers = true;
              hyperlinks = true;
            };
            merge = {
              conflictStyle = "zdiff3";
            };
            diff = {
              colorMoved = "default";
            };
            init.defaultBranch = "main";
            advice.objectNameWarning = false;
            pull.rebase = true;
            safe.directory = "/tmp"; # needed for ago.sh
          };
        };
      programs.lazygit = {
        enable = true;
        enableNushellIntegration = true;
        enableFishIntegration = true;
      };
      home = {
        shellAliases = {
          lg = "${pkgs.lazygit}/bin/lazygit";
        };
        packages = with pkgs; [
          delta
          gh-dash
        ];
      };
    };
}
