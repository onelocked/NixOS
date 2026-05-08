{
  m.default =
    moduleLevel@{
      self',
      wrappers,
      pkgs,
      ...
    }:
    {
      hj.packages = [
        (wrappers.lib.wrapPackage (
          { config, ... }:
          {
            inherit pkgs;
            package = self'.packages.otter-launcher;
            extraPackages = with pkgs; [
              chafa
              pulsemixer
              self'.packages.fsel
            ];
            flags."--config" = config.constructFiles.otter-config.path;
            constructFiles.otter-config =
              let
                resize = width: height: cmd: ''
                  """
                  niri msg action set-window-width ${toString width};niri msg action set-window-height ${toString height};niri msg action center-window;${cmd}
                  """
                '';
              in
              {
                relPath = "config.toml";
                content = # toml
                  ''
                    [general]

                    default_module = "search"
                    empty_module = "search"
                    exec_cmd = "sh -c"
                    vi_mode = false

                    esc_to_abort = true
                    cheatsheet_entry = "?"
                    cheatsheet_viewer = "less -R; clear"

                    clear_screen_after_execution = true
                    loop_mode = false
                    external_editor = "nvim"
                    delay_startup = 0
                    callback = ""



                    [overlay]
                    overlay_cmd = "chafa -s x11 ${moduleLevel.config.hj.directory}/Pictures/avatars/aemeath.png"
                    overlay_trimmed_lines = 0
                    move_overlay_right = 26
                    move_overlay_down = 1

                    [interface]
                    move_interface_down = 1
                    move_interface_right = 1
                    header = """
                     ┌── \u001B[1;34m $USER@$(echo $HOSTNAME) \u001B[0m ──┐
                     │ \u001B[58m  \u001B[31m  \u001B[32m  \u001B[33m  \u001B[34m  \u001B[35m  \u001B[36m\u001B[0m │
                     │ \u001B[33m \u001B[1;35m system\u001B[0m     NixOS │
                     │ \u001B[36m \u001B[1;35m wm \u001B[0m         $XDG_CURRENT_DESKTOP │
                     │ \u001B[31m \u001B[1;35m loads\u001B[0m       $(cat /proc/loadavg | cut -d ' ' -f 1) │
                     └ \u001B[32m \u001B[1;35m memory\u001B[0m     $(free -h | awk 'FNR == 2 {print $3}') ┘
                       \u001B[90m\u001B[0m  """
                    list_prefix = "   \u001B[90m╰··\u001B[0m \u001B[34m󰅂 "
                    selection_prefix = "   \u001B[1;35m╰━━\u001B[0m \u001B[1;31m❯ "
                    default_module_message = "   \u001B[90m╰··\u001B[0m \u001B[34m  \u001B[33mapp\u001B[0m search"

                    place_holder = "type & search"
                    suggestion_mode = "list"
                    suggestion_lines = 4
                    prefix_color = "\u001B[33m"
                    description_color = "\u001B[39m"
                    place_holder_color = "\u001B[90m"
                    hint_color = "\u001B[90m"


                    [[modules]]
                    description = "run commands"
                    prefix = "sh"
                    cmd = """
                    $(printf $TERM | sed 's/xterm-//g') -e sh -c "{}"
                    """
                    with_argument = true
                    unbind_proc = true


                    #Nixpkgs
                    [[modules]]
                    description = "nix packages"
                    prefix = "np"
                    cmd = "xdg-open 'https://search.nixos.org/packages?channel=unstable&query={}'"
                    with_argument = true
                    url_encode = true
                    unbind_proc = true

                    #Nix Options
                    [[modules]]
                    description = "nix options"
                    prefix = "no"
                    cmd = "xdg-open 'https://search.nixos.org/options?channel=unstable&include_home_manager_options=0&include_modular_service_options=0&include_nixos_options=1&query={}'"
                    with_argument = true
                    url_encode = true
                    unbind_proc = true

                    [[modules]]
                    description = "sys mon"
                    prefix = "btop"
                    cmd = ${resize 2100 1200 "btop"}

                    [[modules]]
                    description = "systemd"
                    prefix = "isd"
                    cmd = ${resize 2100 1200 "isd"}

                    [[modules]]
                    description = "audio"
                    prefix = "mix"
                    cmd = ${resize 800 500 "pulsemixer"}

                    [[modules]]
                    description = "notepad"
                    prefix = "nap"
                    cmd = ${resize 2500 1200 "nap"}

                    [[modules]]
                    description = "video"
                    prefix = "mpv"
                    cmd = "mpv-wlpaste"

                    [[modules]]
                    description = "yazi"
                    prefix = "y"
                    cmd = ${resize 2100 1100 "yazi"}

                    [[modules]]
                    description = "search apps with fsel"
                    prefix = "search"
                    cmd = ${resize 450 650 "`fsel --launch-prefix='app2unit --' -vv -d -r -ss \"{}\"`"}
                    with_argument = true

                    [[modules]]
                    description = "launch apps instantly"
                    prefix = "app"
                    cmd = ${resize 450 650 "`fsel --launch-prefix='app2unit --' -vv -d -r -p \"{}\""}
                    with_argument = true
                  '';
              };
          }
        ))
      ];
      hj.xdg.config.files."fsel/config.toml" =
        let
          tomlFormat = pkgs.formats.toml { };
        in
        {
          generator = tomlFormat.generate "fsel-config";
          value = {
            main_border_color = "#7d75c0";
            apps_border_color = "#7d75c0";
            input_border_color = "#c8b0e8";

            main_text_color = "#cfd3e7";
            apps_text_color = "#8c92aa";
            input_text_color = "#c8b0e8";

            highlight_color = "#c5c0ff";
            header_title_color = "#7d75c0";

            pin_color = "#c8b0e8";
            pin_icon = "󰐃";
            cursor = "▎";
            disable_mouse = true;

            rounded_borders = true;
            title_panel_height_percent = 20;
            title_panel_position = "bottom";
            fancy_mode = true;

            app_launcher = {
              filter_desktop = true;
              filter_actions = true;
              list_executables_in_path = false;
              launch_prefix = [
                "app2unit"
                "--"
              ];
            };
            dmenu = {
              delimiter = " ";
              show_line_numbers = true;
            };
          };
        };
      custom.programs.niri.settings.binds = {
        "Mod+SPACE" = _: {
          props = {
            repeat = false;
            hotkey-overlay-title = "Launcher";
          };
          content = {
            spawn-sh = [ "pkill otter-launcher || kitty -1 --app-id=otter-launcher -e otter-launcher" ];
          };
        };
      };
    };
  envoy.otter-launcher.github = "kuokuo123/otter-launcher";
  perSystem =
    {
      pkgs,
      lib,
      envoy,
      ...
    }:
    {
      packages.otter-launcher = pkgs.rustPlatform.buildRustPackage {
        inherit (envoy.otter-launcher) pname version src;
        cargoHash = "sha256-AlzCrK6DivOfCMGXQsiMJ+7Ahtd/9qoJ0MKZrez6xyM=";
        meta = {
          description = "A hackable cli/tui launcher built for keyboard-centric wm users, featuring vi & emacs keybinds, ansi decoration, etc";
          homepage = "https://github.com/kuokuo123/otter-launcher";
          license = lib.licenses.gpl3Only;
          mainProgram = "otter-launcher";
        };
      };
      packages.fsel = pkgs.rustPlatform.buildRustPackage {
        pname = "fsel";
        version = "0-unstable-2026-04-19";
        src = pkgs.fetchFromGitHub {
          owner = "Mjoyufull";
          repo = "fsel";
          rev = "ad49c5d96bb1b1b738c5ce6f4410ecffea8adb5c";
          hash = "sha256-pBQMSlEUICEfmzA+oSonzH0JlAcBjsVE0gT0QwsTNFE=";
        };
        cargoHash = "sha256-hNDiVdEOT3X6YSjggZgj1ZMpy4Ttcu3H7UKe/R1pJfY=";
      };
    };
}
