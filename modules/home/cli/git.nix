{ self, ... }:
{
  flake.modules.homeManager.git =
    { pkgs, config, ... }:
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
        enableNushellIntegration = config.programs.nushell.enable or false;
        enableFishIntegration = config.programs.fish.enable or false;
      };
      home = {
        shellAliases = {
          lg = "${pkgs.lazygit}/bin/lazygit";
        };
        packages = with pkgs; [
          diffnav
          delta
          gh-dash
        ];
      };
    };
}
