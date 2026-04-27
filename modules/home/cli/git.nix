{ self, ... }:
{
  m.git =
    { pkgs, wrappers, ... }:
    {
      programs.git =
        let
          inherit (self.variables) username email;
        in
        {
          enable = true;
          config = {
            user = {
              name = username + "ed";
              inherit email;
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

      nixpkgs.overlays = [
        (
          final: prev:
          let
            yamlFormat = prev.formats.yaml { };
          in
          {
            lazygit = wrappers.lib.wrapPackage {
              pkgs = prev;
              package = prev.lazygit;
              env.LG_CONFIG_FILE = yamlFormat.generate "config.yml" {
                git = {
                  autoFetch = false;
                  overrideGpg = true;
                  pagers = [
                    {
                      pager = ''delta --file-style "#74548c" --features space-separated --dark --diff-highlight --true-color always --paging=never --line-numbers --hyperlinks --hyperlinks-file-link-format="lazygit-edit://{path}:{line}" --line-fill-method=ansi --navigate --keep-plus-minus-markers --commit-style="#8eb893"'';
                    }
                    {
                      pager = ''delta --side-by-side --file-style "#74548c" --features space-separated --dark --diff-highlight --true-color always --paging=never --line-numbers --hyperlinks --hyperlinks-file-link-format="lazygit-edit://{path}:{line}" --line-fill-method=ansi --navigate --keep-plus-minus-markers --commit-style="#8eb893"'';
                    }
                  ];
                  update = {
                    days = 365;
                    method = "never";
                  };
                };

                gui = {
                  authorColors = {
                    "*" = "#b4befe";
                  };
                  expandFocusedSidePanel = true;
                  expandedSidePanelWeight = 2;
                  filterMode = "fuzzy";
                  showBottomLine = false;
                  showNumstatInFilesView = true;
                  showPanelJumps = false;
                  showRandomTip = false;
                  sidePanelWidth = 0.25;
                  theme = {
                    activeBorderColor = [
                      "#c8c5d0"
                      "bold"
                    ];
                    cherryPickedCommitBgColor = [ "#45475a" ];
                    cherryPickedCommitFgColor = [ "#89b4fa" ];
                    defaultFgColor = [ "#cccccc" ];
                    inactiveBorderColor = [ "#c5c0ff" ];
                    optionsTextColor = [ "#aeaeae" ];
                    searchingActiveBorderColor = [ "#f9e2af" ];
                    selectedLineBgColor = [ "#47464f" ];
                    unstagedChangesColor = [ "#f38ba8" ];
                  };
                };

                keybinding = {
                  universal = {
                    jumpToBlock = [
                      "0"
                      "1"
                      "2"
                      "3"
                      "4"
                    ];
                  };
                };

                os = {
                  editInTerminal = true;
                  edit = ''if [ -n "$NVIM" ]; then nvim --server $NVIM --remote-send '<C-\><C-n><cmd>close<cr>' && nvim --server $NVIM --remote {{filename}}; else nvim {{filename}}; fi'';
                  editAtLine = ''if [ -n "$NVIM" ]; then nvim --server $NVIM --remote-send '<C-\><C-n><cmd>close<cr>' && nvim --server $NVIM --remote +{{line}} {{filename}}; else nvim +{{line}} {{filename}}; fi'';
                };
              };
            };
          }
        )
      ];
      hj.packages = with pkgs; [
        lazygit
        diffnav
        gh-dash
        delta
      ];
      environment.shellAliases.lg = "${pkgs.lazygit}/bin/lazygit";
    };
}
