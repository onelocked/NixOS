{
  m.default =
    let
      constants = {
        email = "onelock@mail.com";
        username = "onelock";
        homedir = "/home/onelock";
        hostname = "NixOS";
        locale = "en_GB.UTF-8";
        timezone = "Europe/London";
        stateVersion = "25.11";
      };
    in
    {
      _module.args = { inherit constants; };
    };
}
