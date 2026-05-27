{
  m.git =
    { constants, config, ... }:
    {
      sops.secrets.email.owner = constants.username;
      sops.templates."git-email" = {
        owner = constants.username;
        content = ''
          [user]
            email = ${config.sops.placeholder."email"}
        '';
      };
      programs.git = {
        enable = true;
        config = {
          include = {
            path = config.sops.templates."git-email".path;
          };
          user = {
            name = "onelocked";
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
          pager = {
            diff = "diffnav";
            show = "diffnav";
            log = "diffnav";
          };
          init.defaultBranch = "main";
          advice.objectNameWarning = false;
          pull.rebase = true;
          safe.directory = "/tmp";
        };
      };
      forte.lazygit = {
        enable = true;
        withWorktrunk = true;
        settings = {
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
            showFileTree = true;
            showBranchCommitHash = true;
            branchLogGraph = "style";
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
          promptToReturnFromSubprocess = false;
          os = {
            editInTerminal = true;
            edit = ''if [ -n "$NVIM" ]; then nvim --server $NVIM --remote-send '<C-\><C-n><cmd>close<cr>' && nvim --server $NVIM --remote {{filename}}; else nvim {{filename}}; fi'';
            editAtLine = ''if [ -n "$NVIM" ]; then nvim --server $NVIM --remote-send '<C-\><C-n><cmd>close<cr>' && nvim --server $NVIM --remote +{{line}} {{filename}}; else nvim +{{line}} {{filename}}; fi'';
          };
          customCommands = [
            {
              key = "D";
              command = "git show {{.SelectedLocalCommit.Hash}} | diffnav";
              context = "commits";
              output = "terminal"; # Updated from subprocess = true;
              description = "Open selected commit in diffnav";
            }
          ];
        };
      };
    };
  m.default =
    {
      pkgs,
      config,
      lib,
      birdee,
      ...
    }:
    let
      cfg = config.forte.lazygit;
      yamlFormat = pkgs.formats.yaml { };
      tomlFormat = pkgs.formats.toml { };
    in
    {
      config = lib.mkMerge [
        (lib.mkIf cfg.enable {
          hj.packages = [
            cfg.package
            pkgs.gh
          ];
          hj.environment.sessionVariables = {
            GIT_PAGER = "diffnav";
          };
          programs.fish.functions.lg = # fish
            ''
              set -x LAZYGIT_NEW_DIR_FILE ${config.hj.xdg.config.directory}/lazygit/newdir
              command ${lib.getExe cfg.package} $argv
              if test -f $LAZYGIT_NEW_DIR_FILE
                cd (cat $LAZYGIT_NEW_DIR_FILE)
                rm -f $LAZYGIT_NEW_DIR_FILE
              end
            '';
        })
        (lib.mkIf (cfg.enable && cfg.withWorktrunk) {
          hj.packages = [ cfg.worktrunkPackage ];
          programs.fish.interactiveShellInit = "${lib.getExe cfg.worktrunkPackage} config shell init fish | source ";
        })
      ];
      options.forte.lazygit = {
        enable = lib.mkEnableOption "lazygit";
        withWorktrunk = lib.mkEnableOption "worktrunk integration";
        settings = lib.mkOption {
          default = { };
          inherit (yamlFormat) type;
          description = "Options to go into otter-launcher's toml config";
        };
        package = lib.mkOption {
          type = lib.types.package;
          default = birdee.lib.wrapPackage (
            { config, ... }:
            {
              inherit pkgs;
              package = pkgs.lazygit;
              env.LG_CONFIG_FILE = config.constructFiles.generatedConfig.path;
              constructFiles.generatedConfig = {
                relPath = "config.toml";
                builder = ''mkdir -p "$(dirname "$2")" && cp ${yamlFormat.generate "lazygit.yml" cfg.settings} "$2"'';
              };
              runtimePkgs = with pkgs; [
                diffnav
                delta
              ];
            }
          );
        };
        worktrunkPackage = lib.mkOption {
          type = lib.types.package;
          default = birdee.lib.wrapPackage {
            inherit pkgs;
            package = pkgs.worktrunk;
            env.WORKTRUNK_CONFIG_PATH = tomlFormat.generate "worktrunk-config.toml" {
              skip-shell-integration-prompt = true;
              skip-commit-generation-prompt = true;
              merge = {
                squash = false;
                commit = false;
                rebase = true;
                remove = false;
                verify = true;
                ff = true;
              };
            };
          };
        };
      };
    };
}
