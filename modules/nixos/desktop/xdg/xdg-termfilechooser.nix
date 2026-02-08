{ self, ... }:
{
  flake.modules = {
    nixos.desktop =
      { lib, ... }:
      let
        inherit (lib) mkForce;
      in
      {
        xdg.portal.config = {
          common = {
            "org.freedesktop.impl.portal.FileChooser" = mkForce [
              "termfilechooser"
            ];
          };
          niri = {
            "org.freedesktop.impl.portal.FileChooser" = mkForce [
              "termfilechooser"
            ];
          };
        };
      };
    homeManager.state = {
      xdg.configFile = {
        "xdg-desktop-portal-termfilechooser/config".text = ''
          [filechooser]
          cmd=yazi-wrapper.sh
          default_dir=${self.variables.homedir}/Downloads
          open_mode=suggested
          save_mode=default
        '';
        "xdg-desktop-portal-termfilechooser/yazi-wrapper.sh" = {
          executable = true;
          text = # bash
            ''
              #!/usr/bin/env sh
              set -e

              if [ "$6" -ge 4 ]; then
                  set -x
              fi

              multiple="$1"
              directory="$2"
              save="$3"
              path="$4"
              out="$5"

              cmd="yazi"
              termcmd="ghostty -e"

              if [ "$save" = "1" ]; then
                  set -- --chooser-file="$out" "$path"
              elif [ "$directory" = "1" ]; then
                  set -- --chooser-file="$out" --cwd-file="$out"".1" "$path"
              elif [ "$multiple" = "1" ]; then
                  set -- --chooser-file="$out" "$path"
              else
                  set -- --chooser-file="$out" "$path"
              fi

              command="$termcmd $cmd"
              for arg in "$@"; do
                  escaped=$(printf "%s" "$arg" | sed 's/"/\\"/g')
                  command="$command \"$escaped\""
              done

              sh -c "$command"

              if [ "$directory" = "1" ]; then
                  if [ ! -s "$out" ] && [ -s "$out"".1" ]; then
                      cat "$out"".1" > "$out"
                      rm "$out"".1"
                  else
                      rm "$out"".1"
                  fi
              fi
            '';
        };
      };
    };
  };
}
