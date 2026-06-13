{
  exo.mods.desktop =
    {
      self',
      config,
      lib,
      pkgs,
      birdee,
      ...
    }:
    let
      cfg = config.forte.cliphist-tui;
    in
    {
      options.forte.cliphist-tui = {
        enable = lib.mkEnableOption "cliphist-tui" // {
          default = config.forte.otter-launcher.enable;
        };
        package = lib.mkOption {
          default = birdee.lib.wrapPackage {
            inherit pkgs;
            package = self'.packages.cliphist-tui;
            runtimePkgs = [
              self'.packages.cliphist
              pkgs.chafa
              pkgs.ffmpegthumbnailer
            ];
          };

        };
      };
      config = lib.mkIf (cfg.enable) {
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

        forte.otter-launcher = {
          modules = [
            {
              description = "cliphist";
              "prefix" = "cc";
              cmd = config.forte.lib.resize 750 900 "cliphist-tui";
            }
          ];
        };

        systemd.user.services = {
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

      };
    };
  envoy.cliphist-tui.github = "SHORiN-KiWATA/cliphist-tui";
  envoy.cliphist.github = "sentriz/cliphist";
  perSystem =
    {
      birdee,
      envoy,
      pkgs,
      ...
    }:
    {
      packages.cliphist-tui = pkgs.rustPlatform.buildRustPackage (finalAttrs: {
        inherit (envoy.cliphist-tui) pname version src;
        doCheck = false;
        cargoHash = "sha256-KHlEw5RZNeCYeNngPvgDFvBFMKD2OZrx8sg2QWdwjQ8=";
        patches = [
          (pkgs.writeText "better-binds.patch" # rust
            ''
              diff --git a/src/main.rs b/src/main.rs
              index 16ec468..a651026 100644
              --- a/src/main.rs
              +++ b/src/main.rs
              @@ -288,12 +288,13 @@ fn run_tui() {
                       .env("GOMAXPROCS", "2")
                       .arg("--ansi").arg("--listen").arg(port.to_string())
                       .arg(format!("--bind=ctrl-r:reload({exe} list)"))
              -        .arg(format!("--bind=ctrl-x:execute-silent({exe} delete {{1}})+reload({exe} list)"))
              +        .arg(format!("--bind=ctrl-b:execute-silent({exe} delete {{1}})+reload({exe} list)"))
                       .arg(format!("--bind=alt-x:execute-silent({exe} delete-all)+reload({exe} list)"))
                       .arg(format!("--bind=ctrl-o:execute-silent({exe} open {{1}})"))
                       .arg(format!("--bind=ctrl-e:execute-silent({exe} open {{1}})"))
                       .arg("--prompt=󰅍 > ")
              -        .arg("--header=C^-X: Delete | Alt+X: D-All | C^-R: Reload | C^-O/E: Open | Enter/C^-F: Paste")
              +        .arg("--header=C^-B: Delete | Alt+X: D-All | C^-R: Reload | C^-O/E: Open | Enter/C^-F: Paste")
              +        .arg("--height=100%")
                       .arg("--color=header:italic:yellow,prompt:blue,pointer:blue")
                       .arg("--info=hidden").arg("--no-sort").arg("--layout=reverse")
                       .arg("--with-nth=2..").arg("--delimiter=\t")
              --
              2.53.0
            ''
          )
        ];
      });

      packages.cliphist = birdee.lib.wrapPackage {
        inherit pkgs;
        env.CLIPHIST_MAX_STORE_SIZE = "1GB";
        package = pkgs.buildGoModule (finalAttrs: {
          inherit (envoy.cliphist) pname version src;
          doCheck = false;
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
          vendorHash = "sha256-fDl+ul1t2Ux1w5WcCo6YMJtrcC20o+eUEO3NNycSNvI=";
          postInstall = ''
            cp ${finalAttrs.src}/contrib/* $out/bin/
          '';
          buildInputs = [ pkgs.bash ];
        });
      };
    };
}
