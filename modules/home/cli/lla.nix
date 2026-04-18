{
  flake.modules.nixos.lla =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    let
      tomlFormat = pkgs.formats.toml { };
      _ = lib.getExe;
    in
    {
      environment.shellAliases = with pkgs; {
        ls = "${_ lla} --sort-dirs-first --no-dotfiles";
        la = "${_ lla} --sort-dirs-first";
        ll = "${_ lla} -S";
      };
      hj.files = {
        ".config/lla/config.toml" = {
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

        ".config/lla/themes/abrelshud.toml" = {
          # Add the name here as well
          generator = tomlFormat.generate "lla-theme-abrelshud";
          value = {
            name = "catppuccin_mocha_custom";

            colors = {
              file = "#cfd3e7";
              directory = "#c5c0ff";
              symlink = "#c8b0e8";
              executable = "#b8db8c";
              size = "#8c92aa";
              date = "#8c92aa";
              user = "#e8c4d8";
              group = "#7cb8d4";
              permission_dir = "#c5c0ff";
              permission_read = "#b8db8c";
              permission_write = "#f6d88a";
              permission_exec = "#f4a8b8";
              permission_none = "#a2a2a2";
            };

            special_files = {
              folders = {
                "node_modules" = {
                  h = 0;
                  s = 0;
                  l = 0.15;
                };
                "target" = "#8c92aa";
                "dist" = "#8c92aa";
                ".git" = "#c5c0ff";
                "build" = "#8c92aa";
                ".cache" = "#a2a2a2";
                "*-env" = "#b8db8c";
                "venv" = "#b8db8c";
                ".env" = "#f6d88a";
                "*.d" = "#a8c8f0";
                "*_cache" = "#a2a2a2";
                "*-cache" = "#a2a2a2";
              };

              dotfiles = {
                ".gitignore" = "#7cb8d4";
                ".env" = "#f6d88a";
                ".dockerignore" = "#7cb8d4";
                ".editorconfig" = "#8c92aa";
                ".prettierrc" = "#d4b0d8";
                ".eslintrc" = "#d4b0d8";
                ".babelrc" = "#d4b0d8";
              };

              exact_match = {
                "Dockerfile" = "#7cb8d4";
                "docker-compose.yml" = "#7cb8d4";
                "Makefile" = "#f4a8b8";
                "CMakeLists.txt" = "#f4a8b8";
                "README.md" = "#c5c0ff";
                "LICENSE" = "#8c92aa";
                "package.json" = "#f6d88a";
                "Cargo.toml" = "#f2b8a0";
                "go.mod" = "#7cb8d4";
                "flake.nix" = "#c5c0ff";
                "flake.lock" = "#a2a2a2";
                "shell.nix" = "#a8c8f0";
                "default.nix" = "#a8c8f0";
              };

              patterns = {
                "*rc" = "#d4b0d8";
                "*.min.*" = "#a2a2a2";
                "*.test.*" = "#b8db8c";
                "*.spec.*" = "#b8db8c";
                "*.lock" = "#a2a2a2";
                "*.config.*" = "#7cb8d4";
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
                rust = "#f2b8a0";
                python = "#f6d88a";
                javascript = "#f6d88a";
                typescript = "#a8c8f0";
                java = "#f4a8b8";
                csharp = "#c5c0ff";
                cpp = "#f4a8b8";
                go = "#7cb8d4";
                ruby = "#ff7a6b";
                php = "#d4b0d8";
                swift = "#f2b8a0";
                kotlin = "#c8b0e8";
                nix = "#7cb8d4";
                markup = "#c8b0e8";
                style = "#b8db8c";
                web_config = "#a8c8f0";
                shell = "#b8db8c";
                script = "#8fd4b5";
                doc = "#cfd3e7";
                image = "#f2b8a0";
                video = "#ff7a6b";
                audio = "#d4a8c0";
                data = "#a8c8f0";
                archive = "#d4b0d8";
                rs = "#f2b8a0";
                py = "#f6d88a";
                js = "#f6d88a";
                ts = "#a8c8f0";
                jsx = "#f6d88a";
                tsx = "#a8c8f0";
                vue = "#b8db8c";
                css = "#b8db8c";
                scss = "#b8db8c";
                html = "#c8b0e8";
                md = "#c5c0ff";
                json = "#a8c8f0";
                yaml = "#a8c8f0";
                toml = "#f2b8a0";
                sql = "#7cb8d4";
              };
            };
          };
        };
      };
    };
}
