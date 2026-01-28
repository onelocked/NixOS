{ lib, ... }:

let
  mapAttrsMaybe =
    f: attrs:
      lib.pipe attrs [
        (lib.mapAttrsToList f)
        (builtins.filter (x: x != null))
        builtins.listToAttrs
      ];

  forAllNixFiles =
    dir: f:
      if builtins.pathExists dir then
        lib.pipe dir [
          builtins.readDir
          (mapAttrsMaybe (
            fn: type:
              if fn == "default.nix" then
                null  # skip default.nix
              else if type == "regular" then
                let name = lib.removeSuffix ".nix" fn; in
                lib.nameValuePair name (f "${dir}/${fn}")
              else if type == "directory" && builtins.pathExists "${dir}/${fn}/default.nix" then
                lib.nameValuePair fn (f "${dir}/${fn}")
              else
                null
          ))
        ]
      else
        { };
in
{
  flake.nixosModules.core = forAllNixFiles ./. (fn: fn);
}
