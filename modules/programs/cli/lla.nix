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
              file = base0D;
              directory = base0D;
              symlink = base0E;
              executable = base0B;
              size = base04;
              date = base04;
              user = base0E;
              group = base0C;
              permission_dir = base0D;
              permission_read = base0B;
              permission_write = base0A;
              permission_exec = base08;
              permission_none = base04;
            };

            special_files = {
              folders = {
                "node_modules" = {
                  h = 0;
                  s = 0;
                  l = 0.15;
                };
                "target" = base04;
                "dist" = base04;
                ".git" = base0D;
                "build" = base04;
                ".cache" = base04;
                "*-env" = base0B;
                "venv" = base0B;
                ".env" = base0A;
                "*.d" = base0C;
                "*_cache" = base04;
                "*-cache" = base04;
              };
              dotfiles = {
                ".gitignore" = base0C;
                ".env" = base0A;
                ".dockerignore" = base0C;
                ".editorconfig" = base04;
                ".prettierrc" = base0E;
                ".eslintrc" = base0E;
                ".babelrc" = base0E;
              };
              exact_match = {
                "Dockerfile" = base0C;
                "docker-compose.yml" = base0C;
                "Makefile" = base08;
                "CMakeLists.txt" = base08;
                "README.md" = base0D;
                "LICENSE" = base04;
                "package.json" = base0A;
                "Cargo.toml" = base09;
                "go.mod" = base0C;
                "flake.nix" = base0D;
                "flake.lock" = base04;
                "shell.nix" = base0C;
                "default.nix" = base0C;
              };
              patterns = {
                "*rc" = base0E;
                "*.min.*" = base04;
                "*.test.*" = base0B;
                "*.spec.*" = base0B;
                "*.lock" = base04;
                "*.config.*" = base0C;
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
                rust = base09;
                python = base0A;
                javascript = base0A;
                typescript = base0C;
                java = base08;
                csharp = base0D;
                cpp = base08;
                go = base0C;
                ruby = base12;
                php = base0E;
                swift = base09;
                kotlin = base0D;
                nix = base0C;
                markup = base0E;
                style = base0B;
                web_config = base0C;
                shell = base0B;
                script = base14;
                doc = base04;
                image = base09;
                video = base12;
                audio = base0E;
                data = base0C;
                archive = base0E;
                rs = base09;
                py = base0A;
                js = base0A;
                ts = base0C;
                jsx = base0A;
                tsx = base0C;
                vue = base0B;
                css = base0B;
                scss = base0B;
                html = base0E;
                md = base0D;
                json = base0C;
                yaml = base0C;
                toml = base09;
                sql = base0C;
              };
            };
          };
        };
      };
    };
}
