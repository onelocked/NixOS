{ lib, ... }:
{
  flake = {
    options.variables = lib.mkOption {
      type = lib.types.attrsOf lib.types.unspecified;
      default = {
        email = "onelock@mail.com";
        username = "onelock";
        homedir = "/home/onelock";
        hostname = "NixOS";
        desktop = "niri";
        editor = "onevix";
        browser = "zen";
        terminal = "ghostty";
        terminalFileManager = "yazi";
        locale = "en_GB.UTF-8";
        timezone = "Europe/London";
        kbdLayout = "us,ru";
        consoleKeymap = "us";
      };
    };
  };
}
