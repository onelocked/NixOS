{
  perSystem =
    { pkgs, ... }:
    {
      packages.lla = pkgs.lla.overrideAttrs {
        doCheck = false;
        postPatch = ''
          substituteInPlace lla/src/formatter/column_config.rs \
            --replace-fail '"Permissions".to_string()' '"Perms".to_string()'
        '';
      };
    };
  m.lla =
    {
      pkgs,
      config,
      lib,
      self',
      scheme,
      ...
    }:
    let
      lla = self'.packages.lla;
      tomlFormat = pkgs.formats.toml { };
      _ = lib.getExe;
    in
    {
      environment.shellAliases = {
        ls = "${_ lla} --sort-dirs-first --no-dotfiles";
        la = "${_ lla} --sort-dirs-first";
        ll = "${_ lla} -S";
      };
      hj.xdg.config.files = {
        "lla/config.toml" = {
          generator = tomlFormat.generate "lla-config";
          value = {
            default_sort = "name";
            default_format = "table";
            show_icons = true;
            include_dirs = false;
            permission_format = "octal";
            theme = "abrelshud";
            enabled_plugins = [ ];
            plugins_dir = config.hj.xdg.config.directory + "/lla/plugins";
            exclude_paths = [ ];
            default_depth = 3;
            editor = "";

            sort = {
              dirs_first = true;
              case_sensitive = true;
              natural = true;
            };

            filter = {
              case_sensitive = true;
              no_dotfiles = false;
              respect_gitignore = true;
            };

            formatters = {
              tree = {
                max_lines = 20000;
              };
              grid = {
                ignore_width = false;
                max_width = 200;
              };
              long = {
                hide_group = false;
                relative_dates = false;
                columns = [
                  "name"
                  "permissions"
                  "size"
                  "modified"
                  "user"
                  "group"
                ];
              };
              table = {
                columns = [
                  "name"
                  "modified"
                  "size"
                  "permissions"
                ];
              };
            };

            listers = {
              recursive = {
                max_entries = 20000;
              };
              fuzzy = {
                ignore_patterns = [
                  "node_modules"
                  "target"
                  ".git"
                  ".idea"
                  ".vscode"
                ];
              };
            };
          };
        };

        "lla/themes/abrelshud.toml" = {
          # Add the name here as well
          generator = tomlFormat.generate "lla-theme-abrelshud";
          value = with scheme.withHashtag; {
            name = "catppuccin_mocha_custom";

            colors = {
              file = base0D; # lavender
              directory = base0D; # lavender
              symlink = base0E; # mauve
              executable = base0B; # green
              size = base04; # dark foreground (muted)
              date = base04; # dark foreground (muted)
              user = base0E; # mauve (dusty rose → closest is mauve)
              group = base0C; # cyan
              permission_dir = base0D; # lavender
              permission_read = base0B; # green
              permission_write = base0A; # yellow
              permission_exec = base08; # red/pink
              permission_none = base03; # comments/invisibles (neutral gray)
            };

            special_files = {
              folders = {
                "node_modules" = {
                  h = 0;
                  s = 0;
                  l = 0.15;
                }; # keep as-is (HSL)
                "target" = base04; # muted
                "dist" = base04; # muted
                ".git" = base0D; # lavender
                "build" = base04; # muted
                ".cache" = base03; # neutral gray
                "*-env" = base0B; # green
                "venv" = base0B; # green
                ".env" = base0A; # yellow
                "*.d" = base0C; # cyan
                "*_cache" = base03; # neutral gray
                "*-cache" = base03; # neutral gray
              };
              dotfiles = {
                ".gitignore" = base0C; # cyan
                ".env" = base0A; # yellow
                ".dockerignore" = base0C; # cyan
                ".editorconfig" = base04; # muted
                ".prettierrc" = base0E; # mauve
                ".eslintrc" = base0E; # mauve
                ".babelrc" = base0E; # mauve
              };
              exact_match = {
                "Dockerfile" = base0C; # cyan
                "docker-compose.yml" = base0C; # cyan
                "Makefile" = base08; # red/pink
                "CMakeLists.txt" = base08; # red/pink
                "README.md" = base0D; # lavender
                "LICENSE" = base04; # muted
                "package.json" = base0A; # yellow
                "Cargo.toml" = base09; # orange
                "go.mod" = base0C; # cyan
                "flake.nix" = base0D; # lavender
                "flake.lock" = base03; # neutral gray
                "shell.nix" = base0C; # cyan
                "default.nix" = base0C; # cyan
              };
              patterns = {
                "*rc" = base0E; # mauve
                "*.min.*" = base03; # neutral gray
                "*.test.*" = base0B; # green
                "*.spec.*" = base0B; # green
                "*.lock" = base03; # neutral gray
                "*.config.*" = base0C; # cyan
              };
            };

            extensions = {
              groups = {
                rust = [
                  "rs"
                  "toml"
                ];
                python = [
                  "py"
                  "pyi"
                  "pyw"
                  "ipynb"
                ];
                javascript = [
                  "js"
                  "mjs"
                  "cjs"
                  "jsx"
                ];
                typescript = [
                  "ts"
                  "tsx"
                  "d.ts"
                ];
                java = [
                  "java"
                  "jar"
                  "class"
                ];
                csharp = [
                  "cs"
                  "csx"
                ];
                cpp = [
                  "cpp"
                  "cc"
                  "cxx"
                  "c++"
                  "hpp"
                  "hxx"
                  "h++"
                ];
                go = [ "go" ];
                ruby = [
                  "rb"
                  "erb"
                ];
                php = [
                  "php"
                  "phtml"
                ];
                swift = [ "swift" ];
                kotlin = [
                  "kt"
                  "kts"
                ];
                nix = [ "nix" ];
                markup = [
                  "html"
                  "htm"
                  "xhtml"
                  "xml"
                  "svg"
                  "vue"
                  "wasm"
                  "ejs"
                ];
                style = [
                  "css"
                  "scss"
                  "sass"
                  "less"
                  "styl"
                ];
                web_config = [
                  "json"
                  "json5"
                  "yaml"
                  "yml"
                  "toml"
                  "ini"
                  "conf"
                  "config"
                ];
                shell = [
                  "sh"
                  "bash"
                  "zsh"
                  "fish"
                  "ps1"
                  "psm1"
                  "psd1"
                ];
                script = [
                  "pl"
                  "pm"
                  "t"
                  "tcl"
                  "lua"
                  "vim"
                  "vimrc"
                  "r"
                ];
                doc = [
                  "md"
                  "rst"
                  "txt"
                  "org"
                  "wiki"
                  "adoc"
                  "tex"
                  "pdf"
                  "epub"
                  "doc"
                  "docx"
                  "rtf"
                ];
                image = [
                  "png"
                  "jpg"
                  "jpeg"
                  "gif"
                  "bmp"
                  "tiff"
                  "webp"
                  "ico"
                  "heic"
                ];
                video = [
                  "mp4"
                  "webm"
                  "mov"
                  "avi"
                  "mkv"
                  "flv"
                  "wmv"
                  "m4v"
                  "3gp"
                ];
                audio = [
                  "mp3"
                  "wav"
                  "ogg"
                  "m4a"
                  "flac"
                  "aac"
                  "wma"
                ];
                data = [
                  "csv"
                  "tsv"
                  "sql"
                  "sqlite"
                  "db"
                  "json"
                  "xml"
                  "yaml"
                  "yml"
                ];
                archive = [
                  "zip"
                  "tar"
                  "gz"
                  "bz2"
                  "xz"
                  "7z"
                  "rar"
                  "iso"
                  "dmg"
                ];
              };

              colors = {
                rust = base09; # orange
                python = base0A; # yellow
                javascript = base0A; # yellow
                typescript = base0C; # cyan
                java = base08; # red/pink
                csharp = base0D; # lavender
                cpp = base08; # red/pink
                go = base0C; # cyan
                ruby = base12; # bright red
                php = base0E; # mauve
                swift = base09; # orange
                kotlin = base0D; # blue/indigo
                nix = base0C; # cyan
                markup = base0E; # mauve
                style = base0B; # green
                web_config = base0C; # cyan
                shell = base0B; # green
                script = base14; # bright green
                doc = base03; # light gray/comments
                image = base09; # orange
                video = base12; # bright red
                audio = base0E; # mauve
                data = base0C; # cyan
                archive = base0E; # mauve
                rs = base09; # orange
                py = base0A; # yellow
                js = base0A; # yellow
                ts = base0C; # cyan
                jsx = base0A; # yellow
                tsx = base0C; # cyan
                vue = base0B; # green
                css = base0B; # green
                scss = base0B; # green
                html = base0E; # mauve
                md = base0D; # lavender
                json = base0C; # cyan
                yaml = base0C; # cyan
                toml = base09; # orange
                sql = base0C; # cyan
              };
            };
          };
        };
      };
    };
}
