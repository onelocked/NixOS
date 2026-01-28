{ lib, pkgs }:

let
  cursorsPath = ./.;

  cursorFiles = builtins.attrNames (builtins.readDir cursorsPath);

  nixFiles = lib.filter (file: file != "default.nix" && lib.hasSuffix ".nix" file) cursorFiles;

  cursorPackages = lib.map (
    file:
    let
      attrs = import (cursorsPath + "/${file}");
    in
    {
      name = attrs.name;
      value = pkgs.callPackage ../mk-cursor.nix attrs;
    }
  ) nixFiles;

in

lib.listToAttrs cursorPackages
