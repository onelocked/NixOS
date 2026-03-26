{
  flake.modules.nixos.niri =
    { pkgs, ... }:
    {
      custom.programs.niri.settings.binds = {
        # Unbind side mouse buttons
        "MouseBack" = {
          spawn = null;
          _attrs.repeat = false;
        };
        "MouseForward" = {
          spawn = null;
          _attrs.repeat = false;
        };

        # Core Applications
        "Mod+T" = {
          spawn = [ "${pkgs.foot}/bin/foot" ];
          _attrs.repeat = false;
        };
        "Mod+B" = {
          spawn = [
            "${pkgs.niri-launcher}/bin/niri-launcher"
            "zen-twilight"
            "zen-twilight"
          ];
          _attrs.repeat = false;
        };
        # Noctalia IPC calls
        "Mod+ALT+L" = {
          spawn = [
            "qs"
            "ipc"
            "call"
            "lockScreen"
            "lock"
          ];
          _attrs.repeat = false;
        };
        "Mod+BACKSPACE" = {
          spawn = [
            "qs"
            "ipc"
            "call"
            "sessionMenu"
            "toggle"
          ];
          _attrs.repeat = false;
        };
        "Shift+Alt+W" = {
          spawn = [
            "qs"
            "ipc"
            "call"
            "wallpaper"
            "toggle"
          ];
          _attrs.repeat = false;
        };

        # Hardware Controls via Noctalia
        "ALT+Shift+Equal" = {
          spawn = [
            "qs"
            "ipc"
            "call"
            "brightness"
            "increase"
          ];
          _attrs.repeat = false;
        };
        "ALT+Shift+Minus" = {
          spawn = [
            "qs"
            "ipc"
            "call"
            "brightness"
            "decrease"
          ];
          _attrs.repeat = false;
        };
        "Mod+Alt+Equal" = {
          spawn = [
            "qs"
            "ipc"
            "call"
            "volume"
            "increase"
          ];
          _attrs.repeat = false;
        };
        "Mod+Alt+Minus" = {
          spawn = [
            "qs"
            "ipc"
            "call"
            "volume"
            "decrease"
          ];
          _attrs.repeat = false;
        };
        "ALT+Shift+A" = {
          spawn = [
            "qs"
            "ipc"
            "call"
            "plugin:assistant-panel"
            "toggle"
          ];
          _attrs.repeat = false;
        };

        # Vicinae Launcher / Extensions
        "Mod+Z" = {
          spawn = [
            "vicinae"
            "vicinae://extensions/vicinae/core/search-emojis"
          ];
          _attrs.repeat = false;
        };
        "Shift+Alt+F" = {
          spawn = [
            "vicinae"
            "vicinae://extensions/knoopx/nix"
          ];
          _attrs = {
            repeat = false;
            hotkey-overlay-title = "Nix";
          };
        };
        "Mod+SPACE" = {
          spawn = [
            "vicinae"
            "toggle"
          ];
          _attrs = {
            repeat = false;
            hotkey-overlay-title = "Launcher";
          };
        };
        "Mod+V" = {
          spawn = [
            "vicinae"
            "vicinae://extensions/vicinae/clipboard/history"
          ];
          _attrs.repeat = false;
        };

        # Window Actions
        "Mod+G" = {
          toggle-overview = null;
          _attrs.repeat = false;
        };
        "Mod+Q" = {
          close-window = null;
          _attrs.repeat = false;
        };

        # Navigation
        "Mod+Left".focus-column-left = null;
        "Mod+Down".focus-window-down = null;
        "Mod+Up".focus-window-up = null;
        "Mod+Right".focus-column-right = null;

        # Moving Windows
        "Mod+Ctrl+Left".move-column-left = null;
        "Mod+Ctrl+Down".move-window-down = null;
        "Mod+Ctrl+Up".move-window-up = null;
        "Mod+Ctrl+Right".move-column-right = null;

        # Mouse Wheel Navigation
        "Mod+WheelScrollDown" = {
          focus-column-right = null;
          _attrs.cooldown-ms = 150;
        };
        "Mod+WheelScrollUp" = {
          focus-column-left = null;
          _attrs.cooldown-ms = 150;
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
        "Mod+BracketLeft".consume-or-expel-window-left = null;
        "Mod+BracketRight".consume-or-expel-window-right = null;

        "Mod+R".switch-preset-column-width = null;
        "Mod+Ctrl+R".reset-window-height = null;
        "Mod+F".maximize-column = null;
        "Mod+M".fullscreen-window = null;
        "Mod+Shift+F".toggle-windowed-fullscreen = null;
        "Mod+C".center-column = null;

        "Mod+Minus".set-column-width = "-10%";
        "Mod+Equal".set-column-width = "+10%";

        "Mod+Shift+Minus".set-window-height = "-10%";
        "Mod+Shift+Equal".set-window-height = "+10%";

        "Mod+W".expand-column-to-available-width = null;
        "Mod+SHIFT+W".toggle-window-floating = null;

        # Screenshot
        "Print".screenshot = null;
      };
    };
}
