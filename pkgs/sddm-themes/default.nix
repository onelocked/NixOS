{
  stdenv,
  fetchFromGitHub,
  kdePackages,
  theme ? "onelock",
}:
stdenv.mkDerivation rec {
  pname = "sddm-onelock-theme";
  version = "c46901093452479beb20b6c42a22145b0a37d576";
  dontBuild = true;
  dontWrapQtApps = true;
  # Required Qt6 libraries for SDDM >= 0.21
  propagatedBuildInputs = with kdePackages; [
    qtsvg
    qtmultimedia
    qtvirtualkeyboard
  ];
  src = fetchFromGitHub {
    owner = "onelocked";
    repo = "sddm-onelock-theme";
    rev = "${version}";
    sha256 = "Z1v0vsYeNYcOjvWUR95e9qkdinuUV1WRuJeCJUFHacU=";
  };
  buildPhase = ''
    runHook preBuild
    echo "No build required."
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    # Install theme to a single directory
    install -dm755 "$out/share/sddm/themes/sddm-onelock-theme"
    cp -r ./* "$out/share/sddm/themes/sddm-onelock-theme"

    # Copy fonts system-wide
    install -dm755 "$out/share/fonts"
    cp -r "$out/share/sddm/themes/sddm-onelock-theme/Fonts/." "$out/share/fonts"

    # Update metadata.desktop to load the chosen subtheme
    metaFile="$out/share/sddm/themes/sddm-onelock-theme/metadata.desktop"
    if [ -f "$metaFile" ]; then
      substituteInPlace "$metaFile" \
        --replace "ConfigFile=Themes/onelock.conf" "ConfigFile=Themes/${theme}.conf"
    fi
     runHook postInstall
  '';

  # Propagate Qt6 libraries to user environment
  postFixup = ''
    install -dm755 $out/nix-support
    echo ${kdePackages.qtsvg} >> $out/nix-support/propagated-user-env-packages
    echo ${kdePackages.qtmultimedia} >> $out/nix-support/propagated-user-env-packages
    echo ${kdePackages.qtvirtualkeyboard} >> $out/nix-support/propagated-user-env-packages
  '';
}
