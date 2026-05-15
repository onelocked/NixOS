{
  m.default =
    {
      pkgs,
      self',
      config,
      lib,
      birdie,
      ...
    }:
    let
      cfg = config.forte.cliphist-tui;
    in
    {
      options.forte.cliphist-tui = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Whether to enable otter-launcher.";
        };

        package = lib.mkOption {
          default = birdie.lib.wrapPackage {
            inherit pkgs;
            package = self'.packages.cliphist-tui;
            extraPackages = [
              pkgs.cliphist
              pkgs.chafa
              pkgs.ffmpegthumbnailer
            ];
          };
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
              "--watch"
              "cliphist"
              "store"
            ];
          }
        ];
      };
    };
  envoy.cliphist-tui.github = "SHORiN-KiWATA/cliphist-tui";
  perSystem =
    { envoy, pkgs, ... }:
    {
      packages.cliphist-tui = pkgs.rustPlatform.buildRustPackage (finalAttrs: {
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
}
