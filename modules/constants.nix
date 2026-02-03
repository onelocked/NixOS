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
        shell = "nushell";
        desktop = "niri";
        locale = "en_GB.UTF-8";
        timezone = "Europe/London";
        kbdLayout = "us,ru";
        consoleKeymap = "us";
      };
    };
  };
}
