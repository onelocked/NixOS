{
  m.default =
    {
      self',
      config,
      lib,
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
          default = self'.packages.cliphist-tui;
        };
      };
      config = lib.mkIf (cfg.enable) {
        hj.packages = [ cfg.package ];
        forte.niri.settings = {
          binds = {
            "Mod+V" = _: {
              props = {
                repeat = false;
              };
              content = {
                spawn-sh = [ "pkill cliphist-tui || kitty -1 --app-id=ClipboardHistory -e cliphist-tui" ];
              };
            };
          };
          window-rules = [
            {
              matches = [ { app-id = "^ClipboardHistory$"; } ];
              open-floating = true;
              opacity = 0.95;
              default-column-width.fixed = 750;
              default-window-height.fixed = 900;
            }
          ];
        };
        forte.otter-launcher.settings = {
          modules = [
            {
              description = "cliphist";
              "prefix" = "cc";
              cmd = config.forte.lib.resize 750 900 "cliphist-tui";
            }
          ];
        };

        forte.startup = [
          {
            spawn = [
              "wl-paste"
              "--type"
              "text"
              "--watch"
              "${self'.packages.cliphist}/bin/cliphist"
              "store"
            ];
          }
          {
            spawn = [
              "wl-paste"
              "--type"
              "image"
              "--watch"
              "${self'.packages.cliphist}/bin/cliphist"
              "store"
            ];
          }
        ];
      };
    };
  envoy.cliphist-tui.github = "SHORiN-KiWATA/cliphist-tui";
  envoy.cliphist.github = "sentriz/cliphist";
  perSystem =
    {
      birdee,
      envoy,
      pkgs,
      self',
      ...
    }:
    {
      packages.cliphist-tui = birdee.lib.wrapPackage {
        inherit pkgs;
        runtimePkgs = [
          self'.packages.cliphist
          pkgs.chafa
          pkgs.ffmpegthumbnailer
        ];
        package = pkgs.rustPlatform.buildRustPackage (finalAttrs: {
          inherit (envoy.cliphist-tui) pname version src;
          cargoLock.lockFile = finalAttrs.src + "/Cargo.lock";
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
      };
      packages.cliphist = birdee.lib.wrapPackage {
        inherit pkgs;
        env.CLIPHIST_MAX_STORE_SIZE = "1GB";
        package = pkgs.buildGoModule (finalAttrs: {
          inherit (envoy.cliphist) pname version src;
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
