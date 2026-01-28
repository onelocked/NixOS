{ lib, ... }:

{

  options.constants = {
    username = lib.mkOption {
      type = lib.types.str;
      description = "Main username for the system";
    };

    desktop = lib.mkOption {
      type = lib.types.str;
      description = "Desktop environment to use";
    };

    editor = lib.mkOption {
      type = lib.types.str;
      description = "Default text editor";
    };

    shell = lib.mkOption {
      type = lib.types.str;
      description = "Default shell";
    };

    browser = lib.mkOption {
      type = lib.types.str;
      description = "Default web browser";
    };

    terminal = lib.mkOption {
      type = lib.types.str;
      description = "Default terminal emulator";
    };

    terminalFileManager = lib.mkOption {
      type = lib.types.str;
      description = "Default terminal file manager";
    };

    sddmTheme = lib.mkOption {
      type = lib.types.str;
      description = "SDDM theme to use";
    };

    # System configuration
    hostname = lib.mkOption {
      type = lib.types.str;
      description = "System hostname";
    };

    locale = lib.mkOption {
      type = lib.types.str;
      description = "System locale";
    };

    timezone = lib.mkOption {
      type = lib.types.str;
      description = "System timezone";
    };

    kbdLayout = lib.mkOption {
      type = lib.types.str;
      description = "Keyboard layout";
    };

    consoleKeymap = lib.mkOption {
      type = lib.types.str;
      description = "Console keymap";
    };
  };
}
