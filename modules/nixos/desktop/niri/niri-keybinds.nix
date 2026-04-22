{
  m.niri =
    { pkgs, ... }:
    let
      set = _: { };
    in
    {
      custom.programs.niri.settings.binds = {
        # Unbind side mouse buttons
        "MouseBack" = _: {
          props = {
            repeat = false;
          };
          content = {
            spawn = set;
          };
        };
        "MouseForward" = _: {
          props = {
            repeat = false;
          };
          content = {
            spawn = set;
          };
        };

        # Core Applications
        "Mod+T" = _: {
          props = {
            repeat = false;
          };
          content = {
            spawn = [ "${pkgs.foot}/bin/foot" ];
          };
        };
        "Mod+B" = _: {
          props = {
            repeat = false;
          };
          content = {
            spawn = [
              "${pkgs.niri-launcher}/bin/niri-launcher"
              "zen-twilight"
              "zen-twilight"
            ];
          };
        };

        # Quickshell IPC calls
        "Mod+ALT+L" = _: {
          props = {
            repeat = false;
          };
          content = {
            spawn = [
              "qs"
              "ipc"
              "call"
              "lockScreen"
              "lock"
            ];
          };
        };
        "Mod+BACKSPACE" = _: {
          props = {
            repeat = false;
          };
          content = {
            spawn = [
              "qs"
              "ipc"
              "call"
              "sessionMenu"
              "toggle"
            ];
          };
        };
        "Shift+Alt+W" = _: {
          props = {
            repeat = false;
          };
          content = {
            spawn = [
              "qs"
              "ipc"
              "call"
              "wallpaper"
              "toggle"
            ];
          };
        };

        # Hardware Controls via Quickshell
        "ALT+Shift+Equal" = _: {
          props = {
            repeat = false;
          };
          content = {
            spawn = [
              "qs"
              "ipc"
              "call"
              "brightness"
              "increase"
            ];
          };
        };
        "ALT+Shift+Minus" = _: {
          props = {
            repeat = false;
          };
          content = {
            spawn = [
              "qs"
              "ipc"
              "call"
              "brightness"
              "decrease"
            ];
          };
        };
        "Mod+Alt+Equal" = _: {
          props = {
            repeat = false;
          };
          content = {
            spawn = [
              "qs"
              "ipc"
              "call"
              "volume"
              "increase"
            ];
          };
        };
        "Mod+Alt+Minus" = _: {
          props = {
            repeat = false;
          };
          content = {
            spawn = [
              "qs"
              "ipc"
              "call"
              "volume"
              "decrease"
            ];
          };
        };
        "ALT+Shift+A" = _: {
          props = {
            repeat = false;
          };
          content = {
            spawn = [
              "qs"
              "ipc"
              "call"
              "plugin:assistant-panel"
              "toggle"
            ];
          };
        };

        # Vicinae Launcher / Extensions
        "Mod+Z" = _: {
          props = {
            repeat = false;
          };
          content = {
            spawn = [
              "vicinae"
              "vicinae://launch/core/search-emojis"
            ];
          };
        };
        "Shift+Alt+F" = _: {
          props = {
            repeat = false;
            hotkey-overlay-title = "Nix";
          };
          content = {
            spawn = [
              "vicinae"
              "vicinae://extensions/knoopx/nix"
            ];
          };
        };
        "Mod+SPACE" = _: {
          props = {
            repeat = false;
            hotkey-overlay-title = "Launcher";
          };
          content = {
            spawn = [
              "vicinae"
              "toggle"
            ];
          };
        };
        "Mod+V" = _: {
          props = {
            repeat = false;
          };
          content = {
            spawn = [
              "vicinae"
              "vicinae://launch/clipboard/history"
            ];
          };
        };

        # Window Actions
        "Mod+G" = _: {
          props = {
            repeat = false;
          };
          content = {
            toggle-overview = set;
          };
        };
        "Mod+Q" = _: {
          props = {
            repeat = false;
          };
          content = {
            close-window = set;
          };
        };

        # Navigation
        "Mod+Left".focus-column-left = set;
        "Mod+Down".focus-window-down = set;
        "Mod+Up".focus-window-up = set;
        "Mod+Right".focus-column-right = set;

        # Moving Windows
        "Mod+Ctrl+Left".move-column-left = set;
        "Mod+Ctrl+Down".move-window-down = set;
        "Mod+Ctrl+Up".move-window-up = set;
        "Mod+Ctrl+Right".move-column-right = set;

        # Mouse Wheel Navigation
        "Mod+WheelScrollDown" = _: {
          props = {
            cooldown-ms = 150;
          };
          content = {
            focus-column-right = set;
          };
        };
        "Mod+WheelScrollUp" = _: {
          props = {
            cooldown-ms = 150;
          };
          content = {
            focus-column-left = set;
          };
        };

        # Workspaces
        "Mod+1".focus-workspace = "browser";
        "Mod+2".focus-workspace = "coding";
        "Mod+3".focus-workspace = "social";
        "Mod+4".focus-workspace = "media";
        "Mod+5".focus-workspace = 5;
        "Mod+6".focus-workspace = 6;
        "Mod+7".focus-workspace = 7;
        "Mod+8".focus-workspace = 8;
        "Mod+9".focus-workspace = 9;

        "Mod+Shift+1".move-column-to-workspace = "browser";
        "Mod+Shift+2".move-column-to-workspace = "coding";
        "Mod+Shift+3".move-column-to-workspace = "social";
        "Mod+Shift+4".move-column-to-workspace = "media";
        "Mod+Shift+5".move-column-to-workspace = 5;
        "Mod+Shift+6".move-column-to-workspace = 6;
        "Mod+Shift+7".move-column-to-workspace = 7;
        "Mod+Shift+8".move-column-to-workspace = 8;
        "Mod+Shift+9".move-column-to-workspace = 9;

        # Layout Manipulation
        "Mod+BracketLeft".consume-or-expel-window-left = set;
        "Mod+BracketRight".consume-or-expel-window-right = set;

        "Mod+R".switch-preset-column-width = set;
        "Mod+Ctrl+R".reset-window-height = set;
        "Mod+F".maximize-column = set;
        "Mod+M".fullscreen-window = set;
        "Mod+Shift+F".toggle-windowed-fullscreen = set;
        "Mod+C".center-column = set;

        "Mod+Minus".set-column-width = "-10%";
        "Mod+Equal".set-column-width = "+10%";

        "Mod+Shift+Minus".set-window-height = "-10%";
        "Mod+Shift+Equal".set-window-height = "+10%";

        "Mod+W".expand-column-to-available-width = set;
        "Mod+SHIFT+W".toggle-window-floating = set;

        # Screenshot
        "Print".screenshot = set;
      };
    };
}
