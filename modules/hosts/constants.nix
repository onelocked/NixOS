{
  flake.modules.generic.constants =
    { lib, ... }:
    {
      options.variables = lib.mkOption {
        type = lib.types.attrsOf lib.types.unspecified;
        default = {
          email = "onelock@mail.com";
          username = "onelock";
          desktop = "niri";
          editor = "onevix";
          shell = "nushell";
          browser = "zen";
          terminal = "ghostty";
          terminalFileManager = "yazi";
          sddmTheme = "onelock";
          hostname = "NixOS";
          locale = "en_GB.UTF-8";
          timezone = "Europe/London";
          kbdLayout = "us,ru";
          consoleKeymap = "us";
        };
      };
    };
}
