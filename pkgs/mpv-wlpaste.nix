{
  writeShellApplication,
  wl-clipboard-rs,
  mpv,
  uutils-coreutils-noprefix,
}:
writeShellApplication {
  name = "mpv-wlpaste";
  runtimeInputs = [
    wl-clipboard-rs
    mpv
    uutils-coreutils-noprefix
  ];
  text = # bash
    ''
      url=$(wl-paste | tr -d '[:space:]')
      if [ -z "$url" ]; then
        exit 0
      fi
      case "$url" in
        *tiktok.com*)
          url="''${url%%\?*}"
          ;;
      esac
      exec mpv "$url"
    '';
}
