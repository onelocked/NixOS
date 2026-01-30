{ pkgs }:

let
  pluginNames = [
    "starship"
    "full-border"
    "mediainfo"
    "no-status"
    "ouch"
    "lazygit"
  ];
in
builtins.listToAttrs (
  map (name: {
    inherit name;
    value = pkgs.yaziPlugins.${name};
  }) pluginNames
)
