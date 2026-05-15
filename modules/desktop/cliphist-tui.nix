{
  perSystem =
    { pkgs, ... }:
    {
      packages.cliphist-tui = pkgs.rustPlatform.buildRustPackage (finalAttrs: {
        pname = "cliphist-tui";
        version = "0-unstable-2026-04-26";

        src = pkgs.fetchFromGitHub {
          owner = "SHORiN-KiWATA";
          repo = "cliphist-tui";
          rev = "fd4a47baaba60598603d6c760512d2169479872b";
          hash = "sha256-wjgE9aladixbGfMXVdkvxEBJHKS2BEepbwILZro7d0A=";
        };

        patches = [
          (pkgs.writeText "fix-hardcoded-path.patch" # rust
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
        cargoHash = "sha256-KHlEw5RZNeCYeNngPvgDFvBFMKD2OZrx8sg2QWdwjQ8=";
      });
    };
  m.default =
    {
      pkgs,
      self',
      config,
      ...
    }:
    {
      hj.packages = [
        self'.packages.cliphist-tui
        pkgs.cliphist
        pkgs.chafa
        pkgs.ffmpegthumbnailer
      ];
      forte.niri.settings = {
        # binds = {
        #   "Mod+V" = _: {
        #     props = {
        #       repeat = false;
        #     };
        #     content = {
        #       spawn-sh = [ "pkill cliphist-tui || kitty -1 --app-id=ClipboardHistory -e cliphist-tui" ];
        #     };
        #   };
        # };
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

      # startup = [
      #   {
      #     spawn = [
      #       "wl-paste"
      #       "--watch"
      #       "cliphist"
      #       "store"
      #     ];
      #   }
      # ];
    };
}
