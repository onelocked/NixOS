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
            ];
            flags."--config" = config.constructFiles.otter-config.path;
            constructFiles.otter-config = {
              relPath = "config.toml";
              content = # toml
                ''
                  [general]
                  # module to run when no prefix is matched
                  default_module = "np"
                  # run with an empty prompt
                  empty_module = "mix"
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
                  overlay_cmd = "chafa -s x11 ${moduleLevel.config.hj.directory}/Pictures/avatars/image.png"
                  overlay_trimmed_lines = 1
                  move_overlay_right = 22
                  move_overlay_down = 1

                  [interface]
                  move_interface_down = 1
                  header = """
                   ┌ \u001B[1;34m  $USER@$(echo $HOSTNAME) \u001B[0m───┐
                   │ \u001B[90m󱎘  \u001B[31m󱎘  \u001B[32m󱎘  \u001B[33m󱎘  \u001B[34m󱎘  \u001B[35m󱎘  \u001B[36m󱎘\u001B[0m │
                   └ \u001B[36m󱄅 \u001B[1;36m system\u001B[0m     NixOS ┘
                   ┌ \u001B[33m \u001B[1;36m wm \u001B[0m         $XDG_CURRENT_DESKTOP ┐
                   │ \u001B[31m \u001B[1;36m loads\u001B[0m       $(cat /proc/loadavg | cut -d ' ' -f 1) │
                   │ \u001B[32m \u001B[1;36m memory\u001B[0m     $(free -h | awk 'FNR == 2 {print $3}') │
                   │ \u001B[90m\u001B[0m  """
                  list_prefix = "   └ \u001B[34m󰅂  "
                  selection_prefix = "   └ \u001B[31m󱓞  "
                  default_module_message = "   └ \u001B[34m  \u001B[33msearch\u001B[0m nixpkgs"

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
                  cmd = """
                  niri msg action set-window-width 2100;niri msg action set-window-height 1200;niri msg action center-window;btop
                  """

                  [[modules]]
                  description = "systemd"
                  prefix = "isd"
                  cmd = """
                  niri msg action set-window-width 2100;niri msg action set-window-height 1200;niri msg action center-window;isd
                  """

                  [[modules]]
                  description = "audio"
                  prefix = "mix"
                  cmd = """
                  niri msg action set-window-width 800;niri msg action set-window-height 500;niri msg action center-window;pulsemixer
                  """

                  [[modules]]
                  description = "notepad"
                  prefix = "nap"
                  cmd = """
                  niri msg action set-window-width 2500;niri msg action set-window-height 1200;niri msg action center-window;nap
                  """

                  [[modules]]
                  description = "video"
                  prefix = "mpv"
                  cmd = "mpv-wlpaste"

                  [[modules]]
                  description = "yazi"
                  prefix = "y"
                  cmd = """
                  niri msg action set-window-width 2100;niri msg action set-window-height 1100;niri msg action center-window;yazi
                  """
                '';
            };
          }
        ))
      ];
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
    };
}
