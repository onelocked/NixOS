{
  exo.core =
    { lib, ... }:
    {
      time.timeZone = "Europe/London";
      i18n.defaultLocale = "en_GB.UTF-8";
      i18n.extraLocaleSettings =
        [
          "LC_ADDRESS"
          "LC_IDENTIFICATION"
          "LC_MEASUREMENT"
          "LC_MONETARY"
          "LC_NAME"
          "LC_NUMERIC"
          "LC_PAPER"
          "LC_TELEPHONE"
          "LC_TIME"
        ]
        |> map (locale: lib.nameValuePair locale "en_GB.UTF-8")
        |> builtins.listToAttrs;
    };
}
