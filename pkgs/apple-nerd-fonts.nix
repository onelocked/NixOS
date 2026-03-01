{ stdenv, pkgs, ... }:

stdenv.mkDerivation (finalAttrs: {
  name = "apple-nerd-fonts";
  src = fetchTarball {
    url = "https://s3.onelock.org/download/apple-nerd.tar.gz";
    sha256 = "0ra0rv5cfw6gcdqam370g69afybbagqfyg03lf1l05m2bs3cpr29";
  };

  nativeBuildInputs = [ pkgs.rsync ];

  installPhase = ''
    install -dm755 $out/share/fonts/apple-nerd
    rsync -r --exclude='NY/*Black*' --exclude='NY/*Heavy*' ${finalAttrs.src}/ $out/share/fonts/apple-nerd
  '';
})
