{
  m.rice =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    let
      cfg = config.forte;
      niri = "niri msg action";
      theme = config.forte.theme.variant;
    in
    {
      forte.otter-launcher.modules = [
        {
          description = "showcase";
          prefix = "rice";
          cmd = "${niri} spawn -- ${lib.getExe cfg.lib.rice.script}; exit";
        }
      ];
      forte.niri.settings.workspacesList = [
        {
          name = "rice";
          config = {
            layout = {
              center-focused-column = "never";
              default-column-width = {
                proportion = 0.749;
              };
              preset-column-widths = [
                { proportion = 0.749; }
              ];
            };
          };
        }
      ];

      forte.lib.rice = {
        script = pkgs.writeShellApplication {
          name = "rice";
          runtimeInputs = with pkgs; [
            cfg.niri.package
            cfg.kitty.package
            cfg.yazi.package
            cfg.quickshell.package
            cfg.neovim.package
            qview
            gawk
          ];

          text =
            let
              fastfetchCmd =
                if theme == "dark" then
                  "kitten icat -n --place 20x20@2x1 --scale-up --align left ${
                    pkgs.fetchurl {
                      url = "https://raw.githubusercontent.com/onelocked/images/refs/heads/main/fleet-snowfluff.gif";
                      hash = "sha256-Vz6QZrhr5c+ShiHJwxHFeyCXszWFvDjhKFm2CyQNAbo=";
                    }
                  } | ${lib.getExe cfg.fastfetch.package}"
                else
                  lib.getExe cfg.fastfetch.package;
            in
            ''
               sleep 0.25

               wait_for_window() {
                 local match_type="$1"
                 local match_value="$2"
                 local timeout=20
                 local elapsed=0
                 while [[ $elapsed -lt $timeout ]]; do
                   local window_id
                   if [[ "$match_type" == "app-id" ]]; then
                     window_id=$(niri msg windows 2>/dev/null \
                       | awk -v val="$match_value" '
                         /^Window ID/ { id = $3; gsub(/:/, "", id) }
                         /App ID:/ && $0 ~ val { print id; exit }
                       ')
                   elif [[ "$match_type" == "title" ]]; then
                     window_id=$(niri msg windows 2>/dev/null \
                       | awk -v val="$match_value" '
                         /^Window ID/ { id = $3; gsub(/:/, "", id) }
                         /Title:/ && $0 ~ val { print id; exit }
                       ')
                   fi
                   if [[ -n "$window_id" ]]; then
                     echo "$window_id"
                     return 0
                   fi
                   elapsed=$((elapsed + 1))
                 done
                 echo "ERROR: Timed out waiting for $match_type=$match_value" >&2
                 return 1
               }

               setup_window() {
                 local window_id="$1"
                 local width="$2"
                 local height="$3"
                 local x="$4"
                 local y="$5"
                 ${niri} move-window-to-workspace --window-id "$window_id" rice
                 ${niri} toggle-window-floating --id "$window_id"
                 ${niri} set-window-width --id "$window_id" "$width"
                 ${niri} set-window-height --id "$window_id" "$height"
                 ${niri} move-floating-window --id "$window_id" --x "$x" --y "$y"
               }

               setup_window_no_float() {
                 local window_id="$1"
                 local width="$2"
                 local height="$3"
                 local x="$4"
                 local y="$5"
                 ${niri} move-window-to-workspace --window-id "$window_id" rice
                 ${niri} set-window-width --id "$window_id" "$width"
                 ${niri} set-window-height --id "$window_id" "$height"
                 ${niri} move-floating-window --id "$window_id" --x "$x" --y "$y"
               }

               # --- Spawn all at once ---
               ${niri} spawn -- kitty --app-id="rice-nvim" -e --working-directory="${config.hj.directory}/NixOS" nvim
               ${niri} spawn -- kitty --app-id=CliampMusic -c ${cfg.lib.otter-lib.cliamp-config} -e ${pkgs.cliamp}/bin/cliamp
               ${niri} spawn -- kitty --app-id="rice-yazi" -e yazi "${config.hj.directory}/Pictures/aemeath/ricemeath.jpg"
               ${niri} spawn -- kitty --app-id=otter-launcher -c ${cfg.lib.otter-lib.otter-kitty-conf} -e otter-launcher
               ${niri} spawn -- qview ${config.hj.directory}/Pictures/aemeath/cleanmeath.png
               ${niri} spawn -- kitty --app-id=fastfetch -e bash -c '${fastfetchCmd}; read'

               # --- Setup ---
               nvim_id=$(wait_for_window "app-id" "rice-nvim")
               setup_window "$nvim_id" "782" "1345" "2600" "41"

               cliamp_id=$(wait_for_window "app-id" "CliampMusic")
               setup_window_no_float "$cliamp_id" "780" "1090" "60" "223"

               otter_id=$(wait_for_window "app-id" "otter-launcher")
               setup_window_no_float "$otter_id" ${if theme == "dark" then "885 410" else "620 355"} "932" "913"

               yazi_id=$(wait_for_window "app-id" "rice-yazi")
               setup_window "$yazi_id" "1259" "749" "327" "94"

               fastfetch_id=$(wait_for_window "app-id" "fastfetch")
               setup_window "$fastfetch_id" "823" "331" "1953" "985"

               qview_id=$(wait_for_window "title" "cleanmeath.png")
               setup_window_no_float "$qview_id" "328" "672" "517" "119"

              ${
                if config.forte.theme.variant == "dark" then
                  ''
                    qs ipc call MediaPanel toggle
                  ''
                else
                  ''
                    qs ipc call island dashboard
                  ''
              }
            '';
        };
      };
    };
}
