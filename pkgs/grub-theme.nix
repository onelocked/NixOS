{ stdenv, fetchFromGitHub, ... }:

stdenv.mkDerivation {
  pname = "grub-theme";
  version = "v1.0";
  src = fetchFromGitHub {
    owner = "onelocked";
    repo = "grub2-theme";
    rev = "207dfe09411f08916666acf65bf6262e5ef5e6d0";
    hash = "sha256-ChnML4zm4EnVX/WmZW5RWHnK/tqjXSeR4BK8XfN0xxA=";
  };
  installPhase = ''
    install -dm755 $out
    cp -rf theme/* $out/
  '';
}
