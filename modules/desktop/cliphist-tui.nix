{
  exo.mods.desktop = {
    forte.cliphist-tui = {
      enable = true;
      systemd.startup = true;
    };
  };
  exo.skeleton =
    {
      pkgs,
      lib,
      self',
      wrapPackage,
      config,
      ...
    }:
    let
      cfg = config.forte.cliphist-tui;
    in
    {
      options.forte.cliphist-tui = {
        enable = lib.mkEnableOption "cliphist-tui";
        package = lib.mkOption {
          default = wrapPackage {
            package = self'.packages.cliphist-tui;
            extraPkgs = [
              self'.packages.cliphist
              pkgs.chafa
              pkgs.ffmpegthumbnailer
            ];
          };
        };
        systemd.startup = lib.mkEnableOption "cliphist-systemd-startup";
      };
      config =
        lib.mkIf cfg.enable
        <| lib.mkMerge [
          {
            hj.packages = [ cfg.package ];
            forte.hyprland.lua = {
              window-rules = # lua
                ''
                  hl.window_rule({
                    name         = "cliphist-tui",
                    match        = { class = "ClipboardHistory" },
                    size         = { 830, 1056 },
                    center       = true,
                    float        = true,
                    stay_focused = true,
                    pin          = true,
                    opacity      = "1 override",
                  })
                '';
              keybinds = # lua
                ''
                  hl.bind("SUPER + V", function()
                      local win = hl.get_window("class:ClipboardHistory")
                      if win then
                          hl.dispatch(hl.dsp.window.close({ window = win }))
                      else
                          hl.dispatch(hl.dsp.exec_raw("kitty -1 --app-id=ClipboardHistory -e cliphist-tui"))
                      end
                  end)
                '';
            };
            forte.persist.home.directories = [ ".cache/cliphist" ];
          }
          (lib.mkIf cfg.systemd.startup {
            hj.systemd.services = {
              cliphist-text = {
                description = "Clipboard history service (Text)";
                after = [ "graphical-session.target" ];
                partOf = [ "graphical-session.target" ];
                wantedBy = [ "graphical-session.target" ];

                serviceConfig = {
                  ExecStart = "${pkgs.wl-clipboard}/bin/wl-paste --type text --watch ${self'.packages.cliphist}/bin/cliphist store";
                  Restart = "on-failure";
                };
              };

              cliphist-image = {
                description = "Clipboard history service (Images)";
                after = [ "graphical-session.target" ];
                partOf = [ "graphical-session.target" ];
                wantedBy = [ "graphical-session.target" ];

                serviceConfig = {
                  ExecStart = "${pkgs.wl-clipboard}/bin/wl-paste --type image --watch ${self'.packages.cliphist}/bin/cliphist store";
                  Restart = "on-failure";
                };
              };
            };
          })
        ];
    };
  tack.inputs.fetch = {
    cliphist-tui = "gh:SHORiN-KiWATA/cliphist-tui";
    cliphist = "gh:sentriz/cliphist";
  };
  perSystem =
    {
      wrapPackage,
      inputs,
      pkgs,
      ...
    }:
    {
      remotePackages.cliphist-tui = pkgs.rustPlatform.buildRustPackage (finalAttrs: {
        pname = inputs._meta.cliphist-tui.repo;
        version = inputs._meta.cliphist-tui.rev;
        src = inputs.cliphist-tui;
        doCheck = false;
        cargoLock.lockFile = finalAttrs.src + "/Cargo.lock";
        patches = [
          (pkgs.writeText "better-binds.patch" # rust
            ''
              diff --git a/src/main.rs b/src/main.rs
              index abea42a..4cbead1 100644
              --- a/src/main.rs
              +++ b/src/main.rs
              @@ -663,6 +663,7 @@ fn run_tui(cache_dir: &Path) {
                       .arg("--info=hidden").arg("--no-sort").arg("--layout=reverse")
                       .arg("--with-nth=2..").arg("--delimiter=\t")
                       .arg("--preview-window=down:60%,wrap")
              +         .arg("--height=100%")
                       .arg(format!("--preview={exe} preview {{1}}"))
                       .arg(format!("--bind=enter:execute-silent({exe} copy {{1}})+accept"))
                       .arg(format!("--bind=ctrl-f:execute-silent({exe} copy {{1}})+accept"))
            ''
          )
        ];
      });

      remotePackages.cliphist = wrapPackage {
        env.CLIPHIST_MAX_STORE_SIZE = "1GB";
        package = pkgs.buildGoModule (finalAttrs: {
          pname = inputs._meta.cliphist.repo;
          version = inputs._meta.cliphist.rev;
          src = inputs.cliphist;
          doCheck = false;
          vendorHash = "sha256-fDl+ul1t2Ux1w5WcCo6YMJtrcC20o+eUEO3NNycSNvI=";
          patches = [
            (pkgs.writeText "fix-browser-copy-with-meta.patch" # go
              ''
                diff --git a/cliphist.go b/cliphist.go
                index 8e1eb95..375f807 100644
                --- a/cliphist.go
                +++ b/cliphist.go
                @@ -127,7 +127,7 @@ func store(dbPath string, in io.Reader, maxDedupeSearch, maxItems uint64, minLen
                 	}
                 	defer db.Close()

                -	if len(bytes.TrimSpace(input)) == 0 {
                +	if len(bytes.TrimSpace(input)) == 0 || isBrowserImageFallback(input) {
                 		return nil
                 	}
                 	tx, err := db.Begin(true)
                @@ -564,3 +564,13 @@ func parseSize(s string) (uint64, error) {
                 	}
                 	return num, nil
                 }
                +
                +func isBrowserImageFallback(input []byte) bool {
                +	s := string(input)
                +	const meta = "<meta http-equiv=\"content-type\" content=\"text/html; charset=utf-8\">"
                +	if !strings.HasPrefix(s, meta) {
                +		return false
                +	}
                +	rest := strings.TrimSpace(s[len(meta):])
                +	return strings.HasPrefix(rest, "<img") && strings.HasSuffix(rest, ">")
                +}
                --
                2.53.0
              ''
            )
          ];
        });
      };
    };
}
