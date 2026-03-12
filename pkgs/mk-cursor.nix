{
  stdenvNoCC,
  name,
  url,
  sha256,
}:

stdenvNoCC.mkDerivation {
  inherit name;

  src = fetchTarball {
    inherit url sha256;
  };

  installPhase = ''
    install -dm755 $out/share/icons/${name}
    cp -rf ./* $out/share/icons/${name}
  '';
}
